class Transaction {
  constructor({
    transactionId,
    amount,
    bankId,
    senderId,
    receiverId,
    status,
    createdAt,
  } = {}) {
    this.transactionId = transactionId;
    this.amount = amount;
    this.bankId = bankId;
    this.senderId = senderId;
    this.receiverId = receiverId;
    this.status = status;
    this.createdAt = createdAt;
  }
}

module.exports = Transaction;
