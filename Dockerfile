ARG aws_default_region=ap-southeast2
ARG project
ARG application
ARG parameter_provider=aws/ssm/v1
ARG secret_provider=aws/ssm/v1
ARG template_provider=aws/ssm/v1
FROM alpine:3.14
RUN apk add --no-cache python3 py3-pip
RUN pip install dsocli
ENV AWS_DEFAULT_REGION=$aws_default_region
ENV DSO_PROJECT=$project
ENV DSO_APPLICATION=$application
RUN dso config init && \
    dso config set parameter.provider.id $parameter_provider && \
    dso config set secret.provider.id $secret_provider && \
    dso config set template.provider.id $template_provider

