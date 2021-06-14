FROM golang:1.14

WORKDIR /go/src/app
COPY . .
RUN go get -u github.com/gofiber/fiber
RUN go get -d ./...
RUN go install ./...

EXPOSE 8001

CMD ["app"]