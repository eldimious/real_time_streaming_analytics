const mapper = require('./mapper');

module.exports.init = (dataStores) => {
  const { anomalyTransactionsDataStore } = dataStores;

  const urlAddressesRepository = {
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
      try {
        const urlAddressEntity = await anomalyTransactionsDataStore.createAnomalyTransaction({
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
        });
        return mapper.toDomainModel(urlAddressEntity);
      } catch (e) {
        console.error('Create anomaly transaction failed with error:', e);
        throw e;
      }
    },

    async getAnomalyTransaction({
      trxId,
      transaction,
      lock,
    }) {
      try {
        const urlAddressEntity = await anomalyTransactionsDataStore.getAnomalyTransaction({
          trxId,
          transaction,
          lock,
        });
        if (!urlAddressEntity) { return null; }
        return mapper.toDomainModel(urlAddressEntity);
      } catch (e) {
        console.error('Get anomaly transaction failed with error:', e);
        throw e;
      }
    },
  };

  return Object.create(urlAddressesRepository);
};
