require('dotenv').config();

const config = {
  basicAuthUsername: process.env.BASIC_AUTH_USERNAME,
  basicAuthPassword: process.env.BASIC_AUTH_PASSWORD,
};

module.exports = config;
