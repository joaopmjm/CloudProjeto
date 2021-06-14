FROM golang:1.14

WORKDIR /go/src/app
COPY . .
RUN go get -u github.com/gofiber/fiber && go get -d ./... && go install ./...

EXPOSE 8001

CMD ["app"]