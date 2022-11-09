# syntax=docker/dockerfile:1
FROM node:16.13.2
WORKDIR /src
COPY ./ /src
RUN npm install
CMD ["npm", "start", ":prod"]
