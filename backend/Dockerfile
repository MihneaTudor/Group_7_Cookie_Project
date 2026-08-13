FROM golang:1.19.2-bullseye
WORKDIR /app
COPY . .
RUN go mod download
RUN go build -o /godocker
ENV REDIS_DNS=redis
EXPOSE 9000
CMD ["/godocker"]