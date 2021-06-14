FROM golang:1.14

WORKDIR /go/src/app
COPY . .
RUN go get -u github.com/gorilla/mux && go get -d ./... && go install ./... && go run main.go

EXPOSE 8001

CMD ["app"]