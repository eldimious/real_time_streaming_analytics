/* eslint-disable no-prototype-builtins */
const databaseContainer = require('./data/infrastructure/db');
const {
  database: databaseConfig,
} = require('./configuration');
const dispatcherRepositoryContainer = require('./data/repositories/dispatcher');
const anomalyTransactionsRepositoryContainer = require('./data/repositories/anomalyTransactions');
const anomalyTransactionsDataStoreContainer = require('./data/repositories/anomalyTransactions/dataStore');
const anomalyTransactionsServiceContainer = require('./domain/anomalyTransactions/service');

const db = databaseContainer.init({ databaseUri: databaseConfig.uri });
const dispatcherRepository = dispatcherRepositoryContainer.init();
const anomalyTransactionsRepository = anomalyTransactionsRepositoryContainer.init({
  anomalyTransactionsDataStore: anomalyTransactionsDataStoreContainer.init(db.schemas),
});
const anomalyTransactionsService = anomalyTransactionsServiceContainer.init({
  anomalyTransactionsRepository,
  dispatcherRepository,
});

async function loadDatabase() {
  await db.sync();
  return db.sequelize;
}
let sequelize = null;

exports.handler = async function detectAnomaly(event, context, callback) {
  try {
    await db.sync();
    console.log('Database connection established');
    if (!sequelize) {
      sequelize = await loadDatabase();
    } else {
      sequelize.connectionManager.initPools();
      if (sequelize.connectionManager.hasOwnProperty('getConnection')) {
        delete sequelize.connectionManager.getConnection;
      }
    }
    await Promise.all(event.Records.map(async (record) => {
      const payload = Buffer.from(record.kinesis.data, 'base64').toString('utf8');
      console.log('Decoded payload:', payload);
      const trx = JSON.parse(payload);
      console.log('event:', trx);
      await anomalyTransactionsService.detectTransactionAnomaly(trx);
    }));
    const response = {
      statusCode: 200,
      body: JSON.stringify('Hello from Lambda!'),
    };
    return response;
  } catch (error) {
    console.error('Detect transaction anomaly error: ', error);
    const response = {
      statusCode: 500,
      body: JSON.stringify('error'),
    };
    return response;
  } finally {
    // close any opened connections during the invocation
    // this will wait for any in-progress queries to finish before closing the connections
    await sequelize.connectionManager.close();
  }
};
