# ugc-pipeline: staticka Go binarka, bezi na Sparku vedle ComfyUI.
FROM golang:1.26 AS build
WORKDIR /src
COPY go.mod ./
COPY cmd/ ./cmd/
COPY internal/ ./internal/
RUN CGO_ENABLED=0 go build -o /ugc-pipeline ./cmd/ugc-pipeline

FROM alpine:3.20
RUN apk add --no-cache ca-certificates
COPY --from=build /ugc-pipeline /usr/local/bin/ugc-pipeline
VOLUME /spool
EXPOSE 8092
ENTRYPOINT ["ugc-pipeline"]
