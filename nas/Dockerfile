# ugc-api: multi-stage, vysledek je jedna staticka binarka.
FROM golang:1.26 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY *.go ./
RUN CGO_ENABLED=0 go build -o /ugc-api .

FROM alpine:3.20
RUN apk add --no-cache ca-certificates
COPY --from=build /ugc-api /usr/local/bin/ugc-api
VOLUME /data
EXPOSE 8095
ENTRYPOINT ["ugc-api"]
