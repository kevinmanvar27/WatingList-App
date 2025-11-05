class RestaurantUser {
  final int id;
  final String username;
  final String mobile;
  final int personCount;

  RestaurantUser({
    required this.id,
    required this.username,
    required this.mobile,
    required this.personCount,
  });

  factory RestaurantUser.fromJson(Map<String, dynamic> json) {
    return RestaurantUser(
      id: json["id"],
      username: json["username"],
      mobile: json["mobile_number"],
      personCount: json["total_users_count"],
    );
  }
}
