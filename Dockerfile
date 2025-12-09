# syntax=docker/dockerfile:1

FROM --platform=$TARGETPLATFORM golang:1.24@sha256:9771a50d67f2b4a56aaf55483f1261e0368973df6db6ec942ea59864ca969788 AS build
ARG TARGETPLATFORM
ARG project_name=generator
ARG build_in_docker=false

WORKDIR /src
COPY . /src

RUN mkdir -p dist/$TARGETPLATFORM

RUN --mount=type=cache,target=/go/pkg/mod/ \
    if [ "$build_in_docker" = "true" ]; then \
        go mod download -x; \
    fi


RUN --mount=type=cache,target=/go/pkg/mod/ \
    if [ "$build_in_docker" = "true" ]; then \
        CGO_ENABLED=0 go build -ldflags="-s -w" -v -o dist/$TARGETPLATFORM/$project_name; \
    fi

FROM --platform=$TARGETPLATFORM bitnami/kubectl:latest@sha256:3bcc3efefff77a4dd3ec1886e612c249dc6a313fada8348e42ec2ebe9168126f AS final
ARG TARGETPLATFORM
ARG project_name=generator
ARG build_in_docker=false

WORKDIR /src

COPY --from=build src/keygen.sh .
COPY --from=build src/dist/$TARGETPLATFORM/$project_name ./generator

ARG version
ARG tag
ENV VERSION=${version:-develop}
ENV TAG=${tag:-main}

USER root
RUN chmod +x /src/keygen.sh
USER 1001

ENTRYPOINT [ "./keygen.sh" ]
