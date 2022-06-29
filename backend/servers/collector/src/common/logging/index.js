const winston = require('winston');
const expressWinston = require('express-winston');
const {
  PRODUCTION_ENV,
  VERBOSE_LOGGING_LVL,
  INFO_LOGGING_LVL,
} = require('../constants');

const getTransports = () => {
  const transports = [
    new winston.transports.Console(),
  ];
  return transports;
};

const getFormat = () => winston.format.combine(
  winston.format.colorize(),
  winston.format.simple(),
);

const requestLogger = expressWinston.logger({
  transports: getTransports(),
  format: getFormat(),
  meta: true,
  msg: 'HTTP {{req.method}} {{req.url}}',
  expressFormat: true,
  colorize: true,
  ignoreRoute() { return false; },
  skip(req, res) {
    return res.statusCode >= 400;
  },
});

const errorLogger = expressWinston.errorLogger({
  transports: getTransports(),
  format: getFormat(),
  meta: true,
  msg: 'HTTP {{req.method}} {{req.url}}',
  expressFormat: true,
  colorize: true,
});

const logger = winston.createLogger({
  level: process.env.NODE_ENV !== PRODUCTION_ENV ? VERBOSE_LOGGING_LVL : INFO_LOGGING_LVL,
  format: getFormat(),
  transports: getTransports(),
});

module.exports = {
  requestLogger: requestLogger.bind(logger),
  errorLogger: errorLogger.bind(logger),
  raw: logger,
  error: logger.error.bind(logger),
  warn: logger.warn.bind(logger),
  info: logger.info.bind(logger),
  log: logger.log.bind(logger),
  verbose: logger.verbose.bind(logger),
  debug: logger.debug.bind(logger),
  silly: logger.silly.bind(logger),
};