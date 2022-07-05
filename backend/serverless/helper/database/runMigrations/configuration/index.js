require('dotenv').config();

const config = {
  database: {
    uri: `postgres://${process.env.POSTGRES_USER}:${process.env.POSTGRES_PASSWORD}@${process.env.POSTGRES_HOST}:${process.env.POSTGRES_PORT}/${process.env.POSTGRES_DB}`,
  },
};

module.exports = config;

// require('dotenv').config();
// const AWS = require('aws-sdk');

// module.exports = async function getConfig() {
//   try {
//     const client = new AWS.SecretsManager({
//       region: process.env.AWS_REGION,
//     });
//     const sendgridApiKey = await client.getSecretValue({ SecretId: process.env.SENDGRIX_X_API_KEY_SECRET_NAME });
//     const dbUser = await client.getSecretValue({ SecretId: process.env.POSTGRES_USER_SECRET_NAME });
//     const dbPass = await client.getSecretValue({ SecretId: process.env.POSTGRES_PASSWORD_SECRET_NAME });
//     return {
//       database: {
//         uri: `postgres://${dbUser}:${dbPass}@${process.env.POSTGRES_HOST}:${process.env.POSTGRES_PORT}/${process.env.POSTGRES_DB}`,
//       },
//     };
//   } catch (err) {
//     console.error('Error retrieving secrets', err);
//     throw err;
//   }
// };