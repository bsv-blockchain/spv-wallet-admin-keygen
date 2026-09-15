# syntax=docker/dockerfile:1

FROM --platform=$TARGETPLATFORM golang:1.27@sha256:f44f6e88636cfb311f9ebace870ded69d943f227bb3cb27d32ffd84ea18c43ea AS build
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

FROM --platform=$TARGETPLATFORM bitnami/kubectl:latest@sha256:b29d8c1665b70817259ceecaea16ab27aab6368b48daf485d19436c809067492 AS final
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
