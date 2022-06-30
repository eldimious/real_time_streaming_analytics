/* eslint-disable prefer-object-spread */
const Sequelize = require('sequelize');
const { PRODUCTION_ENV } = require('../../../common/constants');
const schemasContainer = require('./schemas');

module.exports.init = function init(config) {
  if (!config.databaseUri) {
    throw new Error('Missing databaseUri on configuration file');
  }
  const defaultOptions = {
    dialect: 'postgres',
    operatorsAliases: false,
    logging: true,
    timezone: '+00:00',
    dialectOptions: process.env.NODE_ENV !== PRODUCTION_ENV
      ? {}
      : {
        ssl: {
          require: true,
          rejectUnauthorized: false,
        },
      },
    define: {
      freezeTableName: true,
    },
    pool: {
      /*
       * Lambda functions process one request at a time but your code may issue multiple queries
       * concurrently. Be wary that `sequelize` has methods that issue 2 queries concurrently
       * (e.g. `Model.findAndCountAll()`). Using a value higher than 1 allows concurrent queries to
       * be executed in parallel rather than serialized. Careful with executing too many queries in
       * parallel per Lambda function execution since that can bring down your database with an
       * excessive number of connections.
       *
       * Ideally you want to choose a `max` number where this holds true:
       * max * EXPECTED_MAX_CONCURRENT_LAMBDA_INVOCATIONS < MAX_ALLOWED_DATABASE_CONNECTIONS * 0.8
       */
      max: 2,
      /*
       * Set this value to 0 so connection pool eviction logic eventually cleans up all connections
       * in the event of a Lambda function timeout.
       */
      min: 0,
      /*
       * Set this value to 0 so connections are eligible for cleanup immediately after they're
       * returned to the pool.
       */
      idle: 0,
      // Choose a small enough value that fails fast if a connection takes too long to be established.
      acquire: 3000,
      /*
       * Ensures the connection pool attempts to be cleaned up automatically on the next Lambda
       * function invocation, if the previous invocation timed out. (milliseconds)
       */
      evict: process.env.CURRENT_LAMBDA_FUNCTION_TIMEOUT || '60000',
    },
  };

  const sequelize = new Sequelize(config.databaseUri, { ...defaultOptions, ...config.settings });

  const db = {
    schemas: schemasContainer.init(sequelize),
    async connect() {
      return sequelize.authenticate();
    },
    async disconnect() {
      await sequelize.close();
      return sequelize.connectionManager.close();
    },
    sync: (force = false, alter = false) => {
      sequelize.sync({
        force,
        alter,
      });
    },
    async createTransaction() {
      return sequelize.transaction();
    },
    runTransaction: sequelize.transaction.bind(sequelize),
    sequelize,
  };

  return db;
};
