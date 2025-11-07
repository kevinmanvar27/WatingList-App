import 'dart:async';

class RestaurantUser {
  final int id;
  final String username;
  final String mobile;
  final int personCount;
  bool dineIn;
  Timer? dineInTimer;

  RestaurantUser({
    required this.id,
    required this.username,
    required this.mobile,
    required this.personCount,
    required this.dineIn,
    this.dineInTimer,
  });

  factory RestaurantUser.fromJson(Map<String, dynamic> json) {
    return RestaurantUser(
      id: json["id"] ?? 0,
      username: json["username"] ?? "",
      mobile: json["mobile_number"] ?? json["phone_number"] ?? "",
      personCount: json["total_users_count"] ?? 1,
      dineIn: (json["status"] == "dine_in") ? true : false,
    );
  }
}
