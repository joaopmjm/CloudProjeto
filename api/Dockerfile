FROM golang:1.14

WORKDIR /go/src/app
COPY . .
RUN go get github.com/gofiber/fiber
RUN go get ./...
RUN go install ./...

EXPOSE 8001