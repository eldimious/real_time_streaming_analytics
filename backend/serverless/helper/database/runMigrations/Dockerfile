FROM amazon/aws-lambda-nodejs:14 AS builder
WORKDIR /usr/app

COPY package*.json ./
RUN npm install

COPY ./lib ./lib/

RUN ls -la # for debugging

FROM amazon/aws-lambda-nodejs:14
# CMD ["path-to-file.function-name"]
WORKDIR /usr/app

COPY package*.json ./
RUN npm install --only=prod
COPY --from=builder /usr/app/lib /usr/app/lib
CMD [ "/usr/app/lib/index.handler" ]
