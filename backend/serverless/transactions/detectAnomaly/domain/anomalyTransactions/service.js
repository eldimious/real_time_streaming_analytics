/* eslint-disable new-cap */
const BigNumber = require('bignumber.js');

function init({
  anomalyTransactionsRepository,
}) {
  async function detectTransactionAnomaly({
    trxId,
    amount,
    senderId,
    receiverId,
    senderIban,
    receiverIban,
    senderBankId,
    receiverBankId,
    transactionDate,
  }) {
    try {
      if (BigNumber('amount') <= 1000) {
        return;
      }
      const trx = await anomalyTransactionsRepository.createAnomalyTransaction({
        trxId,
        amount,
        senderId,
        receiverId,
        senderIban,
        receiverIban,
        senderBankId,
        receiverBankId,
        transactionDate,
      });
      console.log('trx doc:', trx);
      // TODO: send email
    } catch (error) {
      console.error('Error when detecting anomaly', error);
      throw error;
    }
  }

  return {
    detectTransactionAnomaly,
  };
}

module.exports.init = init;
