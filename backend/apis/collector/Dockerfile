FROM node:16-alpine as builder
RUN mkdir -p /build

COPY ./package.json ./package-lock.json /build/
WORKDIR /build
RUN npm ci

# Bundle app source
COPY . /build

FROM node:16-alpine

# Create app directory
RUN mkdir -p /home/src
WORKDIR /home/src

COPY --from=builder /build ./

EXPOSE $PORT

ENV NODE_ENV production

CMD ["npm", "start"]