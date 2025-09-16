class TransactionRepository {
  constructor(db) {
    this.db = db;
  }

  async create(transaction) {
    const docRef = this.db.collection('transactions').doc(transaction.reference);
    await docRef.set(transaction.toJSON());
    return transaction;
  }

  async findByReference(reference) {
    const doc = await this.db.collection('transactions').doc(reference).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  async updateStatus(reference, status) {
    await this.db.collection('transactions').doc(reference).update({
      status,
      updatedAt: new Date().toISOString()
    });
  }

  async addToPending(reference, data) {
    await this.db.collection('pending_transactions').doc(reference).set({
      ...data,
      created_at: this.db.FieldValue.serverTimestamp(),
      last_checked: null,
      check_count: 0,
      max_checks: 20
    });
  }

  async removeFromPending(reference) {
    await this.db.collection('pending_transactions').doc(reference).delete();
  }

  async findPendingTransactions(limit = 50) {
    const snapshot = await this.db.collection('pending_transactions')
      .where('check_count', '<', 20)
      .orderBy('last_checked', 'asc')
      .limit(limit)
      .get();
    
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  }
}

module.exports = TransactionRepository;
