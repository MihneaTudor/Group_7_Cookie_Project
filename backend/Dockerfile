FROM golang:1.19.2-bullseye AS builder
WORKDIR /app

# Cache module downloads before copying the full source tree.
COPY go.mod ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /backend .

FROM alpine:3.20
WORKDIR /app

RUN apk add --no-cache ca-certificates

COPY --from=builder /backend /backend

ENV REDIS_DNS=redis

EXPOSE 9000

CMD ["/backend"]