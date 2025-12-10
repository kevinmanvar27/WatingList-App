import 'package:shared_preferences/shared_preferences.dart';



class CreateRestaurant {
  bool success;
  Data data;
  String message;

  CreateRestaurant({
    required this.success,
    required this.data,
    required this.message,
  });

  factory CreateRestaurant.fromJson(Map<String, dynamic> json) {
    return CreateRestaurant(
      success: json['success'] ?? false,
      data: Data.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
      'message': message,
    };
  }
}

class Data {
  int id;
  String? profile;
  String name;
  String contactNumber;
  String location;
  String addressLine1;
  String? addressLine2;
  String city;
  String state;
  String country;
  String postalCode;
  String? latitude;
  String? longitude;
  String isActive;
  int currentWaitingCount;
  int ownerId;
  String ownerName;
  String? description;
  dynamic operatingHours;
  dynamic cuisineType;
  dynamic website;
  DateTime createdAt;
  DateTime updatedAt;
  int operationalStatus;

  Data({
    required this.id,
    this.profile,
    required this.name,
    required this.contactNumber,
    required this.location,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.latitude,
    this.longitude,
    required this.isActive,
    required this.currentWaitingCount,
    required this.ownerId,
    required this.ownerName,
    this.description,
    this.operatingHours,
    this.cuisineType,
    this.website,
    required this.createdAt,
    required this.updatedAt,
    required this.operationalStatus,
  });

  factory Data.fromJson(Map<String, dynamic> json) {

    return Data(
      id: json['id'] ?? 0,
      profile: json['profile'],
      name: json['name'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      location: json['location'] ?? '',
      addressLine1: json['address_line_1'] ?? '',
      addressLine2: json['address_line_2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postal_code'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
      isActive: json['is_active'] ?? '',
      currentWaitingCount: json['current_waiting_count'] ?? 0,
      ownerId: json['owner_id'] ?? 0,
      ownerName: json['owner_name'] ?? '',
      description: json['description'],
      operatingHours: json['operating_hours'],
      cuisineType: json['cuisine_type'],
      website: json['website'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      operationalStatus: json['operational_status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile': profile,
      'name': name,
      'contact_number': contactNumber,
      'location': location,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
      'current_waiting_count': currentWaitingCount,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'description': description,
      'operating_hours': operatingHours,
      'cuisine_type': cuisineType,
      'website': website,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'operational_status': operationalStatus,
    };
  }
}