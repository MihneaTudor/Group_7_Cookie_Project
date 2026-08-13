FROM golang:1.19.2-bullseye

WORKDIR /app

COPY . .
RUN go mod download
RUN go build -o /frontend

ENV BACKEND_DNS=backend
ENV BACKEND_PORT=9000

EXPOSE 8080

CMD ["/frontend"]
