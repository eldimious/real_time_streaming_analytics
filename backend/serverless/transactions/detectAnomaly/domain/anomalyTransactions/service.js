/* eslint-disable new-cap */
const BigNumber = require('bignumber.js');
const {
  sendgrid: {
    senderEmail,
    receiverEmail,
  },
} = require('../../configuration');
const {
  AMOUNT_FOR_ANOMALY_TRANSACTION,
} = require('../../common/constants');

function init({
  anomalyTransactionsRepository,
  dispatcherRepository,
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
      if (BigNumber(amount) <= AMOUNT_FOR_ANOMALY_TRANSACTION) {
        console.log(`transaction with id: ${trxId} has amount less than 1000`);
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
      await dispatcherRepository.sendEmail({
        from: senderEmail,
        to: receiverEmail,
        subject: 'Anomaly in transaction detected',
        text: `We have detected anomaly in following transaction: ${trxId}`,
      });
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
