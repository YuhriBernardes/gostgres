FROM golang:1.15-alpine as build

WORKDIR /build

COPY ./main.go ./
COPY ./go.mod ./

RUN go build -o gostgres main.go

FROM alpine:3.12

WORKDIR /app

COPY ./.env ./
COPY --from=build /build/gostgres ./

ENTRYPOINT ./gostgres
