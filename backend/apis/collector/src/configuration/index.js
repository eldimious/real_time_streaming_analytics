require('dotenv').config();

const config = {
  httpPort: process.env.HTTP_PORT || 3000,
  apiKey: process.env.API_KEY,
  appEnv: process.env.APP_ENV,
  aws: {
    accessKeyId: process.env.AWS_ACCESS_KEY,
    secretAccessKey: process.env.AWS_SECRET_KEY,
    region: process.env.AWS_REGION,
    kinesis: {
      dataStream: {
        streams: {
          TRANSACTIONS_STREAM_NAME: process.env.AWS_KINESIS_TRANSACTIONS_STREAM_NAME,
        },
      },
      firehose: {
        streams: {
          TRANSACTIONS_DELIVERY_STREAM_NAME: process.env.AWS_KINESIS_FIREHOSE_TRANSACTIONS_DELIVERY_STREAM_NAME,
        },
      },
    },
  },
};

module.exports = config;
