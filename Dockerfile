# syntax=docker/dockerfile:1

FROM --platform=$TARGETPLATFORM golang:1.26@sha256:2d6c80227255c3112a4d08e67ba98e58efd3846daf15d9d7d4c389565d881b1a AS build
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

FROM --platform=$TARGETPLATFORM bitnami/kubectl:latest@sha256:e2b97dde9666986c61c56d49aae85a714b89b69392baa531438e74ec34096fb4 AS final
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
