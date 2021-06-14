FROM golang:1.14

WORKDIR /go/src/app
COPY . .
RUN go get -u github.com/gofiber/fiber
RUN sudo cp -r db/ /usr/lib/go/src/
RUN sudo cp -r routes/ /usr/lib/go/src/
RUN go get -d ./...
RUN go install ./...

EXPOSE 8001