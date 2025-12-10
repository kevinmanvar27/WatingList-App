class Purchase {
  bool success;
  String message;
  PurchaseData data;
  Transaction transaction;

  Purchase({
    required this.success,
    required this.message,
    required this.data,
    required this.transaction,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: PurchaseData.fromJson(json['data'] ?? {}),
      transaction: Transaction.fromJson(json['transaction'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
      'transaction': transaction.toJson(),
    };
  }
}

class PurchaseData {
  int userId;
  int subscriptionPlanId;
  DateTime startsAt;
  DateTime expiresAt;
  String status;
  String amountPaid;
  String paymentMethod;
  String transactionId;
  PlanSnapshot planSnapshot;
  DateTime updatedAt;
  DateTime createdAt;
  int id;
  SubscriptionPlan subscriptionPlan;

  PurchaseData({
    required this.userId,
    required this.subscriptionPlanId,
    required this.startsAt,
    required this.expiresAt,
    required this.status,
    required this.amountPaid,
    required this.paymentMethod,
    required this.transactionId,
    required this.planSnapshot,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
    required this.subscriptionPlan,
  });

  factory PurchaseData.fromJson(Map<String, dynamic> json) {
    return PurchaseData(
      userId: json['user_id'] ?? 0,
      subscriptionPlanId: json['subscription_plan_id'] ?? 0,
      startsAt: DateTime.parse(json['starts_at'] ?? DateTime.now().toIso8601String()),
      expiresAt: DateTime.parse(json['expires_at'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
      amountPaid: json['amount_paid']?.toString() ?? '0',
      paymentMethod: json['payment_method'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      planSnapshot: PlanSnapshot.fromJson(json['plan_snapshot'] ?? {}),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      id: json['id'] ?? 0,
      subscriptionPlan: SubscriptionPlan.fromJson(json['subscription_plan'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'subscription_plan_id': subscriptionPlanId,
      'starts_at': startsAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'status': status,
      'amount_paid': amountPaid,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'plan_snapshot': planSnapshot.toJson(),
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'id': id,
      'subscription_plan': subscriptionPlan.toJson(),
    };
  }
}

class PlanSnapshot {
  String name;
  int durationDays;
  String price;
  dynamic features;

  PlanSnapshot({
    required this.name,
    required this.durationDays,
    required this.price,
    required this.features,
  });

  factory PlanSnapshot.fromJson(Map<String, dynamic> json) {
    return PlanSnapshot(
      name: json['name'] ?? '',
      durationDays: json['duration_days'] ?? 0,
      price: json['price']?.toString() ?? '0',
      features: json['features'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'duration_days': durationDays,
      'price': price,
      'features': features,
    };
  }
}

class SubscriptionPlan {
  int id;
  String name;
  int durationDays;
  String price;
  bool isEnabled;
  dynamic description;
  dynamic features;
  int sortOrder;
  DateTime createdAt;
  DateTime updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
    required this.isEnabled,
    required this.description,
    required this.features,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      durationDays: json['duration_days'] ?? 0,
      price: json['price']?.toString() ?? '0',
      isEnabled: json['is_enabled'] ?? false,
      description: json['description'],
      features: json['features'],
      sortOrder: json['sort_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration_days': durationDays,
      'price': price,
      'is_enabled': isEnabled,
      'description': description,
      'features': features,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Transaction {
  int userId;
  int subscriptionPlanId;
  int userSubscriptionId;
  String restaurantName;
  String planName;
  String amount;
  String currency;
  String paymentMethod;
  String transactionId;
  String razorpayPaymentId;
  String razorpayOrderId;
  String razorpaySignature;
  String status;
  PaymentDetails paymentDetails;
  DateTime paymentDate;
  DateTime updatedAt;
  DateTime createdAt;
  int id;

  Transaction({
    required this.userId,
    required this.subscriptionPlanId,
    required this.userSubscriptionId,
    required this.restaurantName,
    required this.planName,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.transactionId,
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.razorpaySignature,
    required this.status,
    required this.paymentDetails,
    required this.paymentDate,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      userId: json['user_id'] ?? 0,
      subscriptionPlanId: json['subscription_plan_id'] ?? 0,
      userSubscriptionId: json['user_subscription_id'] ?? 0,
      restaurantName: json['restaurant_name'] ?? '',
      planName: json['plan_name'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      currency: json['currency'] ?? 'INR',
      paymentMethod: json['payment_method'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      razorpayPaymentId: json['razorpay_payment_id'] ?? '',
      razorpayOrderId: json['razorpay_order_id'] ?? '',
      razorpaySignature: json['razorpay_signature'] ?? '',
      status: json['status'] ?? '',
      paymentDetails: PaymentDetails.fromJson(json['payment_details'] ?? {}),
      paymentDate: DateTime.parse(json['payment_date'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      id: json['id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'subscription_plan_id': subscriptionPlanId,
      'user_subscription_id': userSubscriptionId,
      'restaurant_name': restaurantName,
      'plan_name': planName,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_signature': razorpaySignature,
      'status': status,
      'payment_details': paymentDetails.toJson(),
      'payment_date': paymentDate.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'id': id,
    };
  }
}

class PaymentDetails {
  String razorpayPaymentId;
  String razorpayOrderId;
  String razorpaySignature;
  int amountPaid;
  String currency;

  PaymentDetails({
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.razorpaySignature,
    required this.amountPaid,
    required this.currency,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      razorpayPaymentId: json['razorpay_payment_id'] ?? '',
      razorpayOrderId: json['razorpay_order_id'] ?? '',
      razorpaySignature: json['razorpay_signature'] ?? '',
      amountPaid: json['amount_paid'] ?? 0,
      currency: json['currency'] ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_signature': razorpaySignature,
      'amount_paid': amountPaid,
      'currency': currency,
    };
  }
}
