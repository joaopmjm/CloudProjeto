FROM golang:1.14

WORKDIR /go/src/app
COPY . .

RUN go get -d -v ./...
RUN go install -v ./...

RUN sudo ufw allow 8001/tcp
RUN go run main.go

EXPOSE 8001