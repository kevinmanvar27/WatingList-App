class SubscriptionsStatus {
  bool success;
  List<SubscriptionsStatusDatum> data;

  SubscriptionsStatus({
    required this.success,
    required this.data,
  });

  factory SubscriptionsStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionsStatus(
      success: json['success'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((e) => SubscriptionsStatusDatum.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class SubscriptionsStatusDatum {
  int id;
  int userId;
  int subscriptionPlanId;
  DateTime startsAt;
  DateTime expiresAt;
  String status;
  String amountPaid;
  String paymentMethod;
  String transactionId;
  PlanSnapshot planSnapshot;
  DateTime createdAt;
  DateTime updatedAt;
  SubscriptionPlan2 subscriptionPlan;

  SubscriptionsStatusDatum({
    required this.id,
    required this.userId,
    required this.subscriptionPlanId,
    required this.startsAt,
    required this.expiresAt,
    required this.status,
    required this.amountPaid,
    required this.paymentMethod,
    required this.transactionId,
    required this.planSnapshot,
    required this.createdAt,
    required this.updatedAt,
    required this.subscriptionPlan,
  });

  factory SubscriptionsStatusDatum.fromJson(Map<String, dynamic> json) {
    return SubscriptionsStatusDatum(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      subscriptionPlanId: json['subscription_plan_id'] ?? 0,
      startsAt: DateTime.parse(json['starts_at'] ?? DateTime.now().toIso8601String()),
      expiresAt: DateTime.parse(json['expires_at'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
      amountPaid: json['amount_paid']?.toString() ?? '0',
      paymentMethod: json['payment_method'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      planSnapshot: PlanSnapshot.fromJson(json['plan_snapshot'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      subscriptionPlan: SubscriptionPlan2.fromJson(json['subscription_plan'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subscription_plan_id': subscriptionPlanId,
      'starts_at': startsAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'status': status,
      'amount_paid': amountPaid,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'plan_snapshot': planSnapshot.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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

class SubscriptionPlan2 {
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

  SubscriptionPlan2({
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

  factory SubscriptionPlan2.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan2(
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
