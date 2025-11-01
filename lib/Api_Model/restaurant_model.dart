class RestaurantModel {
  final int id;
  final String name;
  final String location;
  final String fullAddress;
  final String contactNumber;
  final String profile;
  final int waiting;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.location,
    required this.fullAddress,
    required this.contactNumber,
    required this.profile,
    required this.waiting,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      fullAddress: json['full_address'] ?? "",
      contactNumber: json['contact_number'] ?? "",
      profile: json['profile'] ?? "",
      waiting: json['current_waiting_count'] ?? 0,
    );
  }
}
