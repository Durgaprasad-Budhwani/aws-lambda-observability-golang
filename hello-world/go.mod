require (
	github.com/aws/aws-lambda-go v1.35.0
	github.com/davecgh/go-spew v1.1.1
	go.opentelemetry.io/contrib/instrumentation/github.com/aws/aws-lambda-go/otellambda v0.37.0
	go.opentelemetry.io/contrib/instrumentation/github.com/aws/aws-lambda-go/otellambda/xrayconfig v0.37.0
	go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp v0.37.0
	go.opentelemetry.io/contrib/propagators/aws v1.12.0
	go.opentelemetry.io/otel v1.11.2
)

replace gopkg.in/yaml.v2 => gopkg.in/yaml.v2 v2.2.8

module hello-world

go 1.16
