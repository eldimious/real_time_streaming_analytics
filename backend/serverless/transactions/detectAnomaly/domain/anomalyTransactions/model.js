class AnomalyTransaction {
  constructor({
    id,
    trxId,
    amount,
    senderId,
    receiverId,
    senderIban,
    receiverIban,
    senderBankId,
    receiverBankId,
    transactionDate,
    createdAt,
  } = {}) {
    this.id = id;
    this.trxId = trxId;
    this.amount = amount;
    this.senderId = senderId;
    this.receiverId = receiverId;
    this.senderIban = senderIban;
    this.receiverIban = receiverIban;
    this.senderBankId = senderBankId;
    this.receiverBankId = receiverBankId;
    this.transactionDate = transactionDate;
    this.createdAt = createdAt;
  }
}

module.exports = AnomalyTransaction;
