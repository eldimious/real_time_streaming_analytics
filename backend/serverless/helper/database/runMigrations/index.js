const databaseContainer = require('./data/infrastructure/db');
const {
  database: databaseConfig,
} = require('./configuration');

const db = databaseContainer.init({ databaseUri: databaseConfig.uri });
const errors = require('./common/errors');

function sleep(millis) {
  return new Promise((resolve) => setTimeout(resolve, millis));
}

const createResponseError = (err) => ({
  statusCode: err.status,
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    data: {
      code: err.code,
      message: err.message,
    },
  }),
});

function errorHandler(err) {
  const internalError = new errors.InternalServerError(err.message);
  return errors.isHttpError(err) ? createResponseError(err) : createResponseError(internalError);
}

async function loadDatabase() {
  await db.sync(true, true);
  return db.sequelize;
}
let sequelize = null;

exports.handler = async function runMigrations(event, context, callback) {
  try {
    await db.sync(true, true);
    console.log('Database connection established and sync has been made successfully');
    if (!sequelize) {
      sequelize = await loadDatabase();
    } else {
      sequelize.connectionManager.initPools();
      if (sequelize.connectionManager.hasOwnProperty('getConnection')) {
        delete sequelize.connectionManager.getConnection;
      }
    }
    await sleep(10000);
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        data: {
          message: 'Success',
        },
      }),
    };
  } catch (error) {
    console.error('Run migrations error: ', error);
    return errorHandler(error);
  } finally {
    // close any opened connections during the invocation
    // this will wait for any in-progress queries to finish before closing the connections
    await sequelize.connectionManager.close();
  }
};
