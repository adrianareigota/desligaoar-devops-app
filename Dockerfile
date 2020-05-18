FROM node:10-slim

LABEL maintainer="Adriana Reigota <adrianareigota@gmail.com>"

WORKDIR /usr/app
COPY . .

RUN npm install

EXPOSE 3000

ENTRYPOINT ["node", "app.js"]
