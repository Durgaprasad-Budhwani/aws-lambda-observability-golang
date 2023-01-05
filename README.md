
## AWS Lambda Observability — Golang

![](https://cdn-images-1.medium.com/max/3840/1*FUK36U86lLlrTHwBDk8vsw.png)

**Observability** is the ability to understand the state of a system by analyzing its outputs. It is an essential concept in computer science and engineering, as it allows you to monitor and understand the behaviour of complex systems, identify problems, and fix them before they cause significant issues.

There are three main pillars of observability:

1. **Metrics**: Metrics are numerical values that can be collected and monitored over time. They can measure various aspects of a system’s behaviour, such as performance, resource utilization, and errors.

2. **Logs**: Logs are records of events that happen within a system. They can be used to understand the sequence of events that led to a particular problem and to identify trends and patterns over time.

3. **Tracing**: Tracing involves tracking the flow of a request as it travels through a system, from the point of origin to the final destination. It allows you to understand how different system components interact and can be used to identify issues with specific parts of the system.

Using a combination of metrics, logs, and tracing, you can gain a deep understanding of the behaviour of your systems and identify issues before they become significant problems.

In this article, you will learn how to achieve observability in AWS Lambda when the lambda runtime is [**Golang](https://go.dev/) **programming language**.**

## Prerequisite

To get started, you must have the following prerequisites:

* [AWS Account](https://portal.aws.amazon.com/) with AWS Lambda creation access

* [Golang Install](https://go.dev/dl/)

* [AWS CLI ](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)Configure

* [AWS SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html) Install

* [Goland](https://www.jetbrains.com/go/) or VSCode

## Getting Started:

The easiest way to start writing Lambda functions with Golang is by using AWS SAM CLI. It is a command-line tool that you can use to build and test serverless applications defined with AWS Serverless Application Model (SAM)

To create a Go sample application using the AWS SAM CLI, you will need to do the following:

1. Please create a new project directory and navigate to it in your terminal.

2. Run the following command to create a new Go application using the AWS SAM CLI:

   sam init --runtime go1.x

![](https://cdn-images-1.medium.com/max/3268/1*zdlaxMfUkJ_yCaJe7wKX_Q.png)

This will create a new directory with the following structure:

![](https://cdn-images-1.medium.com/max/2140/1*U_xK4fI3Xk_iiP-GM7oMZQ.png)

1. The hello_world the directory contains a sample function that you can use as a starting point for your application. You can modify the main.go file to add your code and use the Makefile to build and test your function.

2. The template.yaml The file contains a SAM template that defines your application's resources, such as AWS Lambda functions and Amazon S3 buckets. You can use this file to define the resources needed by your application.

3. The events the directory contains sample event data you can use to test your function. You can modify the event.json file to create different test scenarios for your function.

hello-world/main.go the file includes the AWS Lambda Handler code:

<iframe src="https://medium.com/media/c5ca0e5db4ef4a745d07f793200a504a" frameborder=0></iframe>

The program consists of two main parts:

1. The main function, which is the entry point of the program. It uses the lambda.Start function to start the AWS Lambda runtime and passes the handler function as the function to be executed when the Lambda function is triggered.

2. The handler function, which is the function that will be executed by AWS Lambda when the function is triggered. The handler function takes an events.APIGatewayProxyRequest as an input, which contains information about the HTTP request, and returns an, which contains the HTTP response that will be returned to the client.

The handler the function does the following:

1. Makes an HTTP GET request to the DefaultHTTPGetAddress URL using the http.Get function.

2. If the request fails, it returns an empty events.APIGatewayProxyResponse and the error.

3. If the request is successful, it checks the HTTP status code of the response. If the status code is not 200, it returns an empty events.APIGatewayProxyResponse and the ErrNon200Response error.

4. If the status code is 200, it reads the response body using the ioutil.ReadAll function and stores the data in the ip variable.

5. If the ip the variable is empty; it returns an empty events.APIGatewayProxyResponse and the ErrNoIP error.

6. If the ip the variable is not empty; it returns an events.APIGatewayProxyResponse with the body set to a string containing the message "Hello, [IP]", where [IP] is the IP address read from the response body and a status code of 200.

### Local Testing:

sam local start-api is a command that you can use to start an API Gateway locally using the AWS Serverless Application Model (SAM) CLI. This can be useful for testing and debugging your serverless applications locally before deploying them to AWS.

After running sam local start-api command, it will start an API Gateway locally and make it available at the default URL: http://127.0.0.1:3000. You can use the URL [http://127.0.0.1:3000/hello](http://127.0.0.1:3000/hello) to send HTTP requests to your locally-running API Gateway, and it will show you the current IP address:

![](https://cdn-images-1.medium.com/max/2000/1*UaYrZgTzpl6i0ij-1nIPGg.png)

You can also specify a different port number using the --port option. For example:

    https://www.google.com/search?q=9%3A00+PM+IST+to+mountain+time&oq=9%3A00+PM+IST+to+mountain+time&aqs=cawrome..69i57.7088j0j4&sourceid=chrome&ie=UTF-8sam local start-api --port 8000

This will start the API Gateway on port 8000.

### **Deployment: **

Once you have written and tested your function, you can use the AWS SAM CLI to package and deploy your application to AWS. To do this, run the following command:

    sam build && sam deploy --guided

This will package your application and deploy it to AWS, creating all the necessary resources in your AWS account.

After successful deployment, it will create a simple stack with AWS Lambda and API Gateway with an endpoint based on API Gateway root resource id e.g.
[https://gbwf8lkzwh.execute-api.us-east-1.amazonaws.com/Prod/hello/](https://gbwf8lkzwh.execute-api.us-east-1.amazonaws.com/Prod/hello/)

![](https://cdn-images-1.medium.com/max/2000/1*sby904FNnv3GKQwEZdiLiw.png)

![](https://cdn-images-1.medium.com/max/2000/1*uIp7Jqu4bZucohUDEL5GKA.png)

### Tracing:

In the .aws-sam/build/template.yaml, tracing is enabled for both the lambda function and the API gateway.

![](https://cdn-images-1.medium.com/max/2000/1*pVHCA_XQH_UEViizoALEpw.png)

You can navigate to AWS X-Ray Service in AWS Console to see end-to-end tracing.

![](https://cdn-images-1.medium.com/max/3172/1*dgSlOYBG3dsRAbeU1jiMPA.png)

**Amazon X-Ray** is a service that helps developers analyze and debug distributed applications, such as those built using a microservices architecture. X-Ray enables you to trace requests as they travel through your application and provides tools to visualize the request data and identify issues with the application.

With X-Ray, you can understand how your application and its underlying resources are performing, identify and troubleshoot the root cause of performance issues, and optimize your application’s performance.

To use X-Ray, you instrument your application code to send data to the X-Ray service. X-Ray then processes and visualizes the data, allowing you to analyze the data and identify issues with your application.

You can use X-Ray with applications running on Amazon EC2, AWS Lambda, and other cloud and on-premises environments.

The above example shows traceability from AWS API Gateway to the AWS Lambda function, but you can’t see traces for the external checkip service.

## Instrumentation:

There are two ways to instrument your Go application to send traces to X-Ray:

* [AWS X-Ray SDK for Go](https://docs.aws.amazon.com/xray/latest/devguide/xray-sdk-go.html) — A set of libraries for generating and sending traces to X-Ray via the [X-Ray daemon](https://docs.aws.amazon.com/xray/latest/devguide/xray-daemon.html).

* [AWS Distro for OpenTelemetry (ADOT) Go](https://docs.aws.amazon.com/xray/latest/devguide/xray-go-opentel-sdk.html) — An AWS distribution that provides a set of open-source libraries for sending correlated metrics and traces to multiple AWS monitoring solutions, including Amazon CloudWatch, AWS X-Ray, and Amazon OpenSearch Service, via the [AWS Distro for OpenTelemetry Collector](https://aws-otel.github.io/docs/getting-started/collector).
>  AWS X-Ray recommends using AWS Distro for OpenTelemetry (ADOT) to instrument your application instead of this X-Ray SDK due to its more comprehensive range of features and instrumentations.
Source — [https://github.com/aws/aws-xray-sdk-go](https://github.com/aws/aws-xray-sdk-go)

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

This layer includes a reduced version of the [**AWS Distro for OpenTelemetry Collector (ADOT Collector)](https://github.com/aws-observability/aws-otel-collector)**, which runs as a Lambda extension.

More information and supported version can be found on this [link](https://aws-otel.github.io/docs/getting-started/lambda/lambda-go)

While writing this article, the layer ARN for (us-east-1 region) is:

* For x86_64architecture:

  arn:aws:lambda:us-east-1:901920570463:layer:aws-otel-collector-amd64-ver-0-66-0:1

* For arm64 architecture

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

![AWS Lambda Downstream HTTP Request ](https://cdn-images-1.medium.com/max/3418/1*wamSnuCJREAV4XdXrOzSUg.png)



## Cleanup

For clean-up, you can use sam delete the command that will delete the CloudFormation stack.

## Source Code

For source code, please refer to the [link](https://github.com/Durgaprasad-Budhwani/aws-lambda-observability-golang)

## Conclusion:

In summary, AWS Lambda provides several features and tools to improve your serverless applications' traceability and observability.

* AWS X-Ray is a service that helps you analyze and debug distributed applications, such as those built using a microservices architecture. You can use X-Ray to trace requests as they travel through your application and visualize the request data to identify issues with your application.

* The OpenTelemetry project provides a set of APIs, libraries, and tools for distributed tracing and metrics collection. You can use the Go implementation of these APIs, go.opentelemetry, to instrument your Go-based AWS Lambda functions and send data to an OpenTelemetry-compatible tracing backend.

* The context package in Go provides a set of types and functions for carrying contextual information in a request. You can use the context.Context type in your AWS Lambda function handlers to pass values between function invocations and to cancel or timeout function execution.

Using these tools and features, you can improve the traceability and observability of your serverless applications and make it easier to identify and debug issues.
