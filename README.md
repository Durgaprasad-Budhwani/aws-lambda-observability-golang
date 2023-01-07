
## Go-AWS Lambda Observability With AWS Distro For OpenTelementry (Part 2)

![](https://cdn-images-1.medium.com/max/3840/1*CvQOY05WfWr0y6HcioJq5Q.png)
>  If you haven’t already, it is highly recommend checking out our previous article on [**Go-Based AWS Lambda Observability With AWS X-Ray SDK using AWS SAM CLI (Part 1)](https://medium.com/techhappily/go-based-aws-lambda-observability-with-aws-x-ray-sdk-using-aws-sam-cli-part-1-d7e50629c46e)** . It provides a comprehensive overview of Observability and is a great resource for anyone looking to how AWS Lambda can be integrated with AWS X-Ray SDK for observability.



AWS Distro for OpenTelemetry (ADOT) is a distribution of the OpenTelemetry observability framework optimized for use on the Amazon Web Services (AWS) platform. It includes pre-built instrumentation for popular AWS services, such as Amazon DynamoDB, Amazon ECS, and Amazon SNS, as well as integrations with AWS X-Ray and Amazon CloudWatch.

ADOT makes it easy for developers to collect, transmit, and analyze telemetry data from their applications and infrastructure running on AWS. It helps them gain visibility into the performance and behaviour of their systems, identify issues, and troubleshoot problems more efficiently.

ADOT is built on top of the open-source OpenTelemetry project, which provides a standard way to instrument applications and collects telemetry data from them. It is designed to be vendor-neutral and interoperable with many observability tools and platforms.

By using ADOT, developers can take advantage of the benefits of OpenTelemetry and seamlessly integrate with the observability tools and services provided by AWS. This allows them to monitor and debug their applications more effectively and improve the reliability and performance of their systems.

There are two ways to instrument your Go application to send traces to X-Ray:

* [AWS X-Ray SDK for Go](https://docs.aws.amazon.com/xray/latest/devguide/xray-sdk-go.html) — A set of libraries for generating and sending traces to X-Ray via the [X-Ray daemon](https://docs.aws.amazon.com/xray/latest/devguide/xray-daemon.html).

* [AWS Distro for OpenTelemetry (ADOT) Go](https://docs.aws.amazon.com/xray/latest/devguide/xray-go-opentel-sdk.html) — An AWS distribution that provides a set of open-source libraries for sending correlated metrics and traces to multiple AWS monitoring solutions, including Amazon CloudWatch, AWS X-Ray, and Amazon OpenSearch Service, via the [AWS Distro for OpenTelemetry Collector](https://aws-otel.github.io/docs/getting-started/collector).
>  AWS X-Ray recommends using AWS Distro for OpenTelemetry (ADOT) to instrument your application instead of this X-Ray SDK due to its more comprehensive range of features and instrumentations.
Source —  [https://github.com/aws/aws-xray-sdk-go](https://github.com/aws/aws-xray-sdk-go)

This article will walk you through manually instrumenting your Lambda function using the ADOT Lambda Go SDK and applying the ADOT Lambda layer to enable end-to-end tracing.

The ADOT Lambda Go SDK supports the provided.al2 Lambda runtime.

### Change the Runtime of AWS Lambda:

To convert from **go1.x **runtime to **provided.al2 **perform the following steps

1. In template.yaml file, change the Runtime to provided.al2 and add Metadata with BuildMethod makefile in the lambda function section e.g.

   HelloWorldFunction:
   Type: AWS::Serverless::Function # More info about Function Resource: https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#awsserverlessfunction
   Properties:
   CodeUri: hello-world/
   Handler: bootstrap.is.the.handler
   Runtime: provided.al2
   Architectures:
   - x86_64
   Events:
   CatchAll:
   Type: Api # More info about API Event Source: https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#api
   Properties:
   Path: /hello
   Method: GET
   Environment: # More info about Env Vars: https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#environment-object
   Variables:
   PARAM1: VALUE
   Metadata:
   BuildMethod: makefile

2. Create a Makefile inside hello-world the folder, which will generate the executable for the AWS Lambda. The executable name should be bootstrap for custom runtime.

   .PHONY: build

   build-HelloWorldFunction:
   env GOOS=linux go build -ldflags="-s -w" -o $(ARTIFACTS_DIR)/bootstrap main.go

### Code Instrumentation:

1. Add dependencies for the [**ADOT Lambda Go SDK](https://pkg.go.dev/go.opentelemetry.io/contrib/instrumentation/github.com/aws/aws-lambda-go/otellambda)** and the [**recommended SDK configuration options for AWS X-Ray](https://pkg.go.dev/go.opentelemetry.io/contrib/instrumentation/github.com/aws/aws-lambda-go/otellambda/xrayconfig)**.

   import (
   "context"
   "errors"
   "fmt"
   "io/ioutil"

   "github.com/aws/aws-lambda-go/events"
   "github.com/aws/aws-lambda-go/lambda"

   "go.opentelemetry.io/contrib/instrumentation/github.com/aws/aws-lambda-go/otellambda"
   "go.opentelemetry.io/contrib/instrumentation/github.com/aws/aws-lambda-go/otellambda/xrayconfig"
   "go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
   "go.opentelemetry.io/contrib/propagators/aws/xray"
   "go.opentelemetry.io/otel"
   )

**OpenTelemetry** is an open-source project that provides a set of APIs, libraries, and tools for distributed tracing and metrics collection. It is designed to be vendor-agnostic, meaning it can be used with various tracing and metrics backends.

The go.opentelemetry the package is the Go implementation of the OpenTelemetry APIs. It provides a set of Go packages that can instrument Go applications and send data to OpenTelemetry-compatible tracing and metrics backends.

2. Add the below code, which uses configured tracer provider and shuts down the tracer provider in main() a function outside of the lambda handler.

   func main() {
   ctx := context.Background()
   tp, err := xrayconfig.NewTracerProvider(ctx)
   if err != nil {
   fmt.Printf("error creating tracer provider: %v", err)
   }
   defer func(ctx context.Context) {
   err := tp.Shutdown(ctx)
   if err != nil {
   fmt.Printf("error shutting down tracer provider: %v", err)
   }
   }(ctx)
   otel.SetTracerProvider(tp)
   otel.SetTextMapPropagator(xray.Propagator{})
   }

You can also configure their custom tracer provider and pass it on to the Go Lambda instrumentation wrapper.

3. Wrap handler in the call to lambda.Start() or lambda.StartHandler() in main() function using the recommended X-Ray configuration options.

   lambda.Start(otellambda.InstrumentHandler(handler, xrayconfig.WithRecommendedOptions(tp)...))

In a Go-based AWS Lambda function, the context package provides several functions that can be used to interact with the execution context of the Lambda function.

The context.Context type represents the execution context of the function. It is passed as an argument to the Lambda function handler and can be used to pass values between function invocations and to cancel or timeout function execution.

The lambda handler code will be changed as follows:

    func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

### Downstream HTTP Request Instrumentation:

The go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp the package is a Go package that provides instrumentation for the net/http Package, which is part of the Go standard library. It allows you to instrument HTTP requests and responses made using the net/http package and send data to an OpenTelemetry-compatible tracing backend.

In the above main.gocode, change the remove net/http and add go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp and change the request call http.Get to otelhttp.Get(ctx, passing the context, which has tracing information.

Complete `main.go` code:

<iframe src="https://medium.com/media/8bfe1894268ed697998738638bd449a2" frameborder=0></iframe>

### Lambda Layer:

AWS Lambda layers are a distribution mechanism for libraries, custom runtimes, and function code. Layers let you manage your in-development function code independently from the unchanging code and resources it uses.

Layers are ZIP archives that contain libraries, a custom runtime, or even custom function code. You can manage layers separately from your function code and share them across multiple functions. This can make managing and maintaining your code more accessible, as you can update and publish a new layer version without updating your functions.

To use a layer with a function, you specify the Amazon Resource Name (ARN) of the layer when you create or update your function. The layer is extracted to the /opt directory in the function execution environment, and its contents are available to the function code at runtime.

For AWS Lambda Observability, the layer includes a reduced version of the [**AWS Distro for OpenTelemetry Collector (ADOT Collector)](https://github.com/aws-observability/aws-otel-collector)**, which runs as a Lambda extension.

More information and supported version can be found on this [link](https://aws-otel.github.io/docs/getting-started/lambda/lambda-go)

While writing this article, the layer ARN for (us-east-1 region) is:

* For x86_64Architecture:

  arn:aws:lambda:us-east-1:901920570463:layer:aws-otel-collector-amd64-ver-0-66-0:1

* For arm64 Architecture:

  arn:aws:lambda:us-east-1:901920570463:layer:aws-otel-collector-arm64-ver-0-66-0:1

To use this layer in the SAM template, modify the template.yaml code:

    HelloWorldFunction:
        Type: AWS::Serverless::Function # More info about Function Resource: https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#awsserverlessfunction
        Properties:
          CodeUri: hello-world/
          Handler: bootstrap.is.the.handler
          Runtime: provided.al2
          Layers:
            - arn:aws:lambda:us-east-1:901920570463:layer:aws-otel-collector-amd64-ver-0-66-0:1
          Architectures:
            - x86_64
          Events:
            CatchAll:
              Type: Api # More info about API Event Source: https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#api
              Properties:
                Path: /hello
                Method: GET
          Environment: # More info about Env Vars: https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#environment-object
            Variables:
              PARAM1: VALUE
        Metadata:
          BuildMethod: makefile

After the deployment, opening the same URL on the browser will show your IP address.

On AWS X-Ray, you can see the downstream HTTP request shown below.

![AWS Lambda Downstream HTTP Request](https://cdn-images-1.medium.com/max/3418/1*wamSnuCJREAV4XdXrOzSUg.png)

## Cleanup

For clean-up, you can use sam delete the command that will delete the CloudFormation stack.

## Source Code

For source code, please refer to the [link](https://github.com/Durgaprasad-Budhwani/aws-lambda-observability-golang)

## Conclusion:

In summary, AWS Lambda provides several features and tools to improve your serverless applications’ traceability and observability.

* AWS X-Ray is a service that helps you analyze and debug distributed applications, such as those built using a microservices architecture. You can use X-Ray to trace requests as they travel through your application and visualize the request data to identify issues with your application.

* The OpenTelemetry project provides a set of APIs, libraries, and tools for distributed tracing and metrics collection. You can use the Go implementation of these APIs, go.opentelemetry, to instrument your Go-based AWS Lambda functions and send data to an OpenTelemetry-compatible tracing backend.

* The context package in Go provides a set of types and functions for carrying contextual information in a request. You can use the context.Context type in your AWS Lambda function handlers to pass values between function invocations and to cancel or timeout function execution.

Using these tools and features, you can improve the traceability and observability of your serverless applications and make it easier to identify and debug issues.


