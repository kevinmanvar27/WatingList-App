import 'dart:async';

class RestaurantUser {
  final int id;
  final int restaurantId;
  final String username;
  final String mobile;
  final int personCount;
  bool dineIn;
  Timer? dineInTimer;

  RestaurantUser({
    required this.id,
    required this.restaurantId,
    required this.username,
    required this.mobile,
    required this.personCount,
    required this.dineIn,
    this.dineInTimer,
  });

  factory RestaurantUser.fromJson(Map<String, dynamic> json) {
    final ridRaw = json["restaurant_id"] ?? json["restaurantId"] ?? (json["restaurant"]?['id']);
    final int restaurantId = ridRaw is int
        ? ridRaw
        : int.tryParse(ridRaw?.toString() ?? "0") ?? 0;

    final mobileStr = (json["mobile_number"] ?? json["phone_number"] ?? "").toString();
    final int persons = json["total_users_count"] is int
        ? (json["total_users_count"] ?? 1)
        : int.tryParse(json["total_users_count"]?.toString() ?? "1") ?? 1;

    return RestaurantUser(
      id: json["id"] ?? 0,
      restaurantId: restaurantId,
      username: json["username"] ?? "",
      mobile: mobileStr,
      personCount: persons,
      dineIn: (json["status"] == "dine_in") ? true : false,
    );
  }
}
