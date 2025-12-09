class SubscriptionPlans {
  bool success;
  List<SubscriptionPlansData> data;

  SubscriptionPlans({
    required this.success,
    required this.data,
  });

}

class SubscriptionPlansData {
  int id;
  String name;
  int durationDays;
  String price;
  bool isEnabled;
  String? description;
  dynamic features;
  int sortOrder;
  DateTime createdAt;
  DateTime updatedAt;

  SubscriptionPlansData({
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

}
