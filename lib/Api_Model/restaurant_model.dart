class RestaurantModel {
  final int id;
  final String name;
  final String location;
  final String fullAddress;
  final String contactNumber;
  final String profile;
  final int waiting;
  final bool operationalStatus;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.location,
    required this.fullAddress,
    required this.contactNumber,
    required this.profile,
    required this.waiting,
    required this.operationalStatus,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    // Build location from city, state, country
    String locationStr = "";
    if (json['city'] != null && json['city'].toString().isNotEmpty) {
      locationStr = json['city'];
    }
    if (json['state'] != null && json['state'].toString().isNotEmpty) {
      locationStr += locationStr.isEmpty ? json['state'] : ", ${json['state']}";
    }
    
    return RestaurantModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      location: locationStr,
      fullAddress: json['full_address'] ?? "",
      contactNumber: json['contact_number'] ?? "",
      profile: json['profile'] ?? "",
      waiting: json['current_waiting_count'] ?? 0,
      operationalStatus: json['is_active'] == true,
    );
  }
}
