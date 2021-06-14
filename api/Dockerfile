FROM golang:1.14

WORKDIR /go/src/app

ADD . ~/CloudProjeto/api/main

COPY . .
RUN go get -u github.com/gorilla/mux && go get -d ./... && go install ./...

EXPOSE 8001

CMD ["app"]

ENTRYPOINT main