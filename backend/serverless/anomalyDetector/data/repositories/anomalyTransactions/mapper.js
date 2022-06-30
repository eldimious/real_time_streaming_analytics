const AnomalyTransaction = require('../../../domain/anomalyTransactions/model');

const toDomainModel = function toDomainModel(databaseDoc) {
  return new AnomalyTransaction({
    id: databaseDoc.id,
    trxId: databaseDoc.trx_id,
    amount: databaseDoc.amount,
    senderId: databaseDoc.sender_id,
    receiverId: databaseDoc.receiver_id,
    senderIban: databaseDoc.sender_iban,
    receiverIban: databaseDoc.receiver_iban,
    senderBankId: databaseDoc.sender_bank_id,
    receiverBankId: databaseDoc.receiver_bank_id,
    transactionDate: databaseDoc.transaction_date,
    redirectCount: databaseDoc.redirect_count,
  });
};

module.exports = {
  toDomainModel,
};
