class WaitingListUsers {
  bool success;
  List<Datum> data;
  String message;

  WaitingListUsers({
    required this.success,
    required this.data,
    required this.message,
  });

  factory WaitingListUsers.fromJson(Map<String, dynamic> json) => WaitingListUsers(
    success: json["success"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "message": message,
  };
}

class Datum {
  int id;
  String username;
  String mobileNumber;
  int totalUsersCount;
  String status;
  int addedBy;
  int restaurantId;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  Datum({
    required this.id,
    required this.username,
    required this.mobileNumber,
    required this.totalUsersCount,
    required this.status,
    required this.addedBy,
    required this.restaurantId,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    username: json["username"],
    mobileNumber: json["mobile_number"],
    totalUsersCount: json["total_users_count"],
    status: json["status"],
    addedBy: json["added_by"],
    restaurantId: json["restaurant_id"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "mobile_number": mobileNumber,
    "total_users_count": totalUsersCount,
    "status": status,
    "added_by": addedBy,
    "restaurant_id": restaurantId,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "deleted_at": deletedAt,
  };
}
