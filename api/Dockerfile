FROM golang:1.14

WORKDIR /go/src/app
COPY . .
RUN go get github.com/gofiber/fiber/v2
RUN go get github.com/gofiber/fiber/v2/middleware/cors
RUN go get github.com/gofiber/fiber/v2/middleware/logger
RUN go get ./...
RUN go install ./...

EXPOSE 8001