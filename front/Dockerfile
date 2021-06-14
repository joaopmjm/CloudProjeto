FROM nginx:alpine
COPY . /usr/share/nginx/html
WORKDIR /go/src/

ADD . ~/CloudProjeto/front/index.html
COPY . .
EXPOSE 80

CMD [ "site" ]
