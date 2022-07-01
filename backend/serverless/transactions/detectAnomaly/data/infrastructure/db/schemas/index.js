const AnomalyTransactionContainer = require('./AnomalyTransaction');

module.exports.init = (sequelize) => ({
  anomalyTransaction: AnomalyTransactionContainer.init(sequelize),
});
