# syntax=docker/dockerfile:1

FROM --platform=$TARGETPLATFORM golang:1.26@sha256:f96cc555eb8db430159a3aa6797cd5bae561945b7b0fe7d0e284c63a3b291609 AS build
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

FROM --platform=$TARGETPLATFORM bitnami/kubectl:latest@sha256:cd9daa0cc6968665402654b887bdc59aba0f774d0d0a36808eb9259fb642aa5c AS final
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
