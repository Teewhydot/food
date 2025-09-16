class Transaction {
  constructor({
    reference,
    userId,
    userName,
    email,
    amount,
    status = 'pending',
    transactionType,
    bookingDetails = {},
    createdAt = new Date().toISOString(),
    updatedAt = new Date().toISOString(),
    metadata = {}
  }) {
    this.reference = reference;
    this.userId = userId;
    this.userName = userName;
    this.email = email;
    this.amount = amount;
    this.status = status;
    this.transactionType = transactionType;
    this.bookingDetails = bookingDetails;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
    this.metadata = metadata;
  }

  toJSON() {
    return {
      reference: this.reference,
      userId: this.userId,
      userName: this.userName,
      email: this.email,
      amount: this.amount,
      status: this.status,
      transactionType: this.transactionType,
      bookingDetails: this.bookingDetails,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      ...this.metadata
    };
  }
}

module.exports = Transaction;
