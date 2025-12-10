/*
class RestaurantModel {
  final int id;
  final String name;
  final String location;
  final String fullAddress;
  final String contactNumber;
  final String profile;
  final String waiting;
  final bool isOpen;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.location,
    required this.fullAddress,
    required this.contactNumber,
    required this.profile,
    required this.waiting,
    required this.isOpen,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? "",
      location: json['location'] as String? ?? "",
      fullAddress: json['full_address'] as String? ?? "",
      contactNumber: json['contact_number'] as String? ?? "",
      profile: json['profile'] as String? ?? "",
      waiting: json['waiting'] as String? ?? "0",
      isOpen: json['is_open'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'full_address': fullAddress,
      'contact_number': contactNumber,
      'profile': profile,
      'waiting': waiting,
      'is_open': isOpen,
    };
  }
}*/
