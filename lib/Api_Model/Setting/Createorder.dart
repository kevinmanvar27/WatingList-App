class Createorder {
  bool success;
  Createorderdata data;

  Createorder({
    required this.success,
    required this.data,
  });

}

class Createorderdata {
  String orderId;
  int amount;
  String currency;
  Plan plan;

  Createorderdata({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.plan,
  });

}

class Plan {
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

  Plan({
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
