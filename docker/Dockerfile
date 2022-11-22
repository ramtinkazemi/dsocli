ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_SESSION_TOKEN
ARG AWS_DEFAULT_REGION
ARG DSO_PROJECT
ARG DSO_APPLICATION
ARG DSO_PARAMETER_PROVIDER_ID
ARG DSO_SECRET_PROVIDER_ID
ARG DSO_TEMPLATE_PROVIDER_ID
FROM alpine:3.14
RUN apk add --no-cache python3 py3-pip && pip install dsocli
# RUN cat <<EOF | dso config init --input - && \
#     dso config add project -rails && \
#     dso config add parameter.provider.id aws/ssm/v1 && \
#     dso config add secret.provider.id aws/ssm/v1 && \
#     dso config add template.provider.id aws/ssm/v1 && \
#     dso template render -s staging --namespace-scope --filter -rails
RUN cat <<EOF | dso config init --input - \n\
project: ${DSO_PROJECT}\n\
application: ${DSO_APPLICATION}\n\
parameter:\n\
  provider:\n\
    id: ${DSO_PARAMETER_PROVIDER_ID}\n\
secret:\n\
  provider:\n\
    id: ${DSO_SECRET_PROVIDER_ID}\n\
template:\n\
  provider:\n\
    id: ${DSO_TEMPLATE_PROVIDER_ID}\n\
EOF


