class PaystackTransactionEntity {
  final String reference;
  final String orderId;
  final String userId;
  final double amount;
  final String currency;
  final String email;
  final String status;
  final String? authorizationUrl;
  final String? accessCode;
  final DateTime createdAt;
  final DateTime? paidAt;
  final Map<String, dynamic>? metadata;

  PaystackTransactionEntity({
    required this.reference,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.email,
    required this.status,
    this.authorizationUrl,
    this.accessCode,
    required this.createdAt,
    this.paidAt,
    this.metadata,
  });

  factory PaystackTransactionEntity.fromJson(Map<String, dynamic> json) {
    return PaystackTransactionEntity(
      reference: json['reference'] ?? '',
      orderId: json['orderId'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'NGN',
      email: json['email'] ?? '',
      status: json['status'] ?? 'pending',
      // Handle both camelCase and snake_case for Firebase Functions response
      authorizationUrl: json['authorizationUrl'] ?? json['authorization_url'],
      accessCode: json['accessCode'] ?? json['access_code'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'])
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'orderId': orderId,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'email': email,
      'status': status,
      'authorizationUrl': authorizationUrl,
      'accessCode': accessCode,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  PaystackTransactionEntity copyWith({
    String? reference,
    String? orderId,
    String? userId,
    double? amount,
    String? currency,
    String? email,
    String? status,
    String? authorizationUrl,
    String? accessCode,
    DateTime? createdAt,
    DateTime? paidAt,
    Map<String, dynamic>? metadata,
  }) {
    return PaystackTransactionEntity(
      reference: reference ?? this.reference,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      email: email ?? this.email,
      status: status ?? this.status,
      authorizationUrl: authorizationUrl ?? this.authorizationUrl,
      accessCode: accessCode ?? this.accessCode,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isPending => status == 'pending';
  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';
  bool get isProcessing => status == 'processing';
}