/* eslint-disable prefer-object-spread */
const httpErrors = require('throw-http-errors');

const isHttpError = (error) => {
  if (Object.keys(httpErrors).includes(error.name) || (error.status && Object.keys(httpErrors).includes(error.status.toString()))) {
    return true;
  }
  return false;
};

module.exports = Object.assign(
  {},
  httpErrors,
  {
    isHttpError,
  },
);
