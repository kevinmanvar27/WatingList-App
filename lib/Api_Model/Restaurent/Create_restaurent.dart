class CreateRestaurent {
  bool success;
  Data data;
  String message;

  CreateRestaurent({
    required this.success,
    required this.data,
    required this.message,
  });

  factory CreateRestaurent.fromJson(Map<String, dynamic> json) {
    return CreateRestaurent(
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
  String profile;
  String name;
  String contactNumber;
  String location;
  String addressLine1;
  String addressLine2;
  String city;
  String state;
  String country;
  String postalCode;
  String latitude;
  String longitude;
  String isActive;
  int currentWaitingCount;
  int ownerId;
  String ownerName;
  String description;
  dynamic operatingHours;
  dynamic cuisineType;
  dynamic website;
  DateTime createdAt;
  DateTime updatedAt;
  int operationalStatus;

  Data({
    required this.id,
    required this.profile,
    required this.name,
    required this.contactNumber,
    required this.location,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.currentWaitingCount,
    required this.ownerId,
    required this.ownerName,
    required this.description,
    required this.operatingHours,
    required this.cuisineType,
    required this.website,
    required this.createdAt,
    required this.updatedAt,
    required this.operationalStatus,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'] ?? 0,
      profile: json['profile'] ?? '',
      name: json['name'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      location: json['location'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      isActive: json['isActive'].toString(),
      currentWaitingCount: json['currentWaitingCount'] ?? 0,
      ownerId: json['ownerId'] ?? 0,
      ownerName: json['ownerName'] ?? '',
      description: json['description'] ?? '',
      operatingHours: json['operatingHours'],
      cuisineType: json['cuisineType'],
      website: json['website'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      operationalStatus: json['operationalStatus'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile': profile,
      'name': name,
      'contactNumber': contactNumber,
      'location': location,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
      'currentWaitingCount': currentWaitingCount,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'description': description,
      'operatingHours': operatingHours,
      'cuisineType': cuisineType,
      'website': website,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'operationalStatus': operationalStatus,
    };
  }
}