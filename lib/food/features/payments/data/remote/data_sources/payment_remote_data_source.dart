import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/card_entity.dart';
import '../../../domain/entities/payment_method_entity.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentMethodEntity>> getPaymentMethods();
  Future<List<CardEntity>> getSavedCards(String userId);
  Future<CardEntity> saveCard(CardEntity card);
  Future<void> deleteCard(String cardId);
  Future<String> processPayment({
    required String paymentMethodId,
    required double amount,
    required String currency,
    required Map<String, dynamic> metadata,
  });
}

class FirebasePaymentRemoteDataSource implements PaymentRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<List<PaymentMethodEntity>> getPaymentMethods() async {
    // These would typically come from your payment provider's API
    // For now, returning static payment methods
    return [
      PaymentMethodEntity(
        id: 'cash',
        name: 'Cash on Delivery',
        type: 'cash',
        iconUrl: 'assets/svgs/cash.svg',
      ),
      PaymentMethodEntity(
        id: 'card',
        name: 'Credit/Debit Card',
        type: 'card',
        iconUrl: 'assets/svgs/mastercard.svg',
      ),
      PaymentMethodEntity(
        id: 'paypal',
        name: 'PayPal',
        type: 'paypal',
        iconUrl: 'assets/svgs/paypal.svg',
      ),
    ];
  }

  @override
  Future<List<CardEntity>> getSavedCards(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_cards')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return CardEntity(
        paymentMethodEntity: PaymentMethodEntity(
          id: doc.id,
          name: data['cardName'] ?? '',
          type: data['cardType'] ?? 'card',
          iconUrl: _getCardIcon(data['cardType'] ?? ''),
        ),
        pan: data['pan'] ?? 0,
        cvv: data['cvv'] ?? 0,
        mExp: data['mExp'] ?? 0,
        yExp: data['yExp'] ?? 0,
      );
    }).toList();
  }

  @override
  Future<CardEntity> saveCard(CardEntity card) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // In production, you would tokenize the card with your payment provider
    // and only store the token, not the actual card details
    final cardRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_cards')
        .add({
      'cardName': card.paymentMethodEntity.name,
      'cardType': card.paymentMethodEntity.type,
      'lastFourDigits': card.pan.toString().substring(
            card.pan.toString().length - 4,
          ),
      'mExp': card.mExp,
      'yExp': card.yExp,
      'createdAt': FieldValue.serverTimestamp(),
      // Never store CVV in production!
      // This is just for demo purposes
    });

    return CardEntity(
      paymentMethodEntity: PaymentMethodEntity(
        id: cardRef.id,
        name: card.paymentMethodEntity.name,
        type: card.paymentMethodEntity.type,
        iconUrl: card.paymentMethodEntity.iconUrl,
      ),
      pan: card.pan,
      cvv: card.cvv,
      mExp: card.mExp,
      yExp: card.yExp,
    );
  }

  @override
  Future<void> deleteCard(String cardId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_cards')
        .doc(cardId)
        .delete();
  }

  @override
  Future<String> processPayment({
    required String paymentMethodId,
    required double amount,
    required String currency,
    required Map<String, dynamic> metadata,
  }) async {
    // In production, this would integrate with Stripe, PayPal, etc.
    // For now, we'll simulate a successful payment
    
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Generate a mock transaction ID
    final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';
    
    // Log the payment in Firestore
    await _firestore.collection('payments').add({
      'transactionId': transactionId,
      'paymentMethodId': paymentMethodId,
      'amount': amount,
      'currency': currency,
      'metadata': metadata,
      'status': 'succeeded',
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return transactionId;
  }

  String _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return 'assets/svgs/visa.svg';
      case 'mastercard':
        return 'assets/svgs/mastercard.svg';
      default:
        return 'assets/svgs/mastercard.svg';
    }
  }
}