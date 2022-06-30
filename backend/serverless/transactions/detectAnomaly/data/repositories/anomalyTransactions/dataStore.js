const anomalyTransactionsDataStore = {
  async getAnomalyTransaction({
    trxId,
    transaction,
    attributes = [],
    lock,
  }) {
    const {
      anomalyTransaction: anomalyTransactionModel,
    } = this.getDbModels();
    if (!trxId) {
      throw new Error('Add transactionId to get transaction entity.');
    }
    const res = await anomalyTransactionModel.findOne({
      where: {
        trxId,
      },
      attributes: attributes && Array.isArray(attributes) && attributes.length > 0
        ? attributes
        : { exclude: [] },
      ...(lock != null && { lock }),
      ...(transaction != null && { transaction }),
    });
    if (!res) {
      return null;
    }
    return res.get({ plain: true });
  },
  async createAnomalyTransaction({
    trxId,
    amount,
    senderId,
    receiverId,
    senderIban,
    receiverIban,
    senderBankId,
    receiverBankId,
    transactionDate,
    transaction,
  }) {
    const {
      anomalyTransaction: anomalyTransactionModel,
    } = this.getDbModels();
    const res = await anomalyTransactionModel.create({
      trx_id: trxId,
      amount,
      sender_id: senderId,
      receiver_id: receiverId,
      sender_iban: senderIban,
      receiver_iban: receiverIban,
      sender_bank_id: senderBankId,
      receiver_bank_id: receiverBankId,
      transaction_date: transactionDate,
    }, {
      ...(transaction != null && { transaction }),
    });
    return res.get({ plain: true });
  },
};

module.exports.init = function init({
  anomalyTransaction,
}) {
  return Object.assign(Object.create(anomalyTransactionsDataStore), {
    getDbModels() {
      return {
        anomalyTransaction,
      };
    },
  });
};
