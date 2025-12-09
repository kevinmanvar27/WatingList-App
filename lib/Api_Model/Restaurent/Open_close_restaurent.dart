class OpenCloseDart {
  bool success;
  Data6 data;
  String message;

  OpenCloseDart({
    required this.success,
    required this.data,
    required this.message,
  });

  factory OpenCloseDart.fromJson(Map<String, dynamic> json) => OpenCloseDart(
    success: json["success"],
    data: Data6.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
    "message": message,
  };
}

class Data6 {
  int id;
  dynamic profile;
  String name;
  String contactNumber;
  String location;
  String addressLine1;
  dynamic addressLine2;
  String city;
  String state;
  String country;
  String postalCode;
  dynamic latitude;
  dynamic longitude;
  String isActive;
  int currentWaitingCount;
  int ownerId;
  String ownerName;
  dynamic description;
  dynamic operatingHours;
  dynamic cuisineType;
  dynamic website;
  DateTime createdAt;
  DateTime updatedAt;
  int operationalStatus;
  Owner owner;

  Data6({
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
    required this.owner,
  });

  factory Data6.fromJson(Map<String, dynamic> json) => Data6(
    id: json["id"],
    profile: json["profile"],
    name: json["name"],
    contactNumber: json["contact_number"],
    location: json["location"],
    addressLine1: json["address_line_1"],
    addressLine2: json["address_line_2"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    postalCode: json["postal_code"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    isActive: json["is_active"],
    currentWaitingCount: json["current_waiting_count"],
    ownerId: json["owner_id"],
    ownerName: json["owner_name"],
    description: json["description"],
    operatingHours: json["operating_hours"],
    cuisineType: json["cuisine_type"],
    website: json["website"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    operationalStatus: json["operational_status"],
    owner: Owner.fromJson(json["owner"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "profile": profile,
    "name": name,
    "contact_number": contactNumber,
    "location": location,
    "address_line_1": addressLine1,
    "address_line_2": addressLine2,
    "city": city,
    "state": state,
    "country": country,
    "postal_code": postalCode,
    "latitude": latitude,
    "longitude": longitude,
    "is_active": isActive,
    "current_waiting_count": currentWaitingCount,
    "owner_id": ownerId,
    "owner_name": ownerName,
    "description": description,
    "operating_hours": operatingHours,
    "cuisine_type": cuisineType,
    "website": website,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "operational_status": operationalStatus,
    "owner": owner.toJson(),
  };
}

class Owner {
  int id;
  String googleId;
  String name;
  String email;
  dynamic emailVerifiedAt;
  String profilePicture;
  bool isAdmin;
  DateTime pinSetAt;
  DateTime createdAt;
  DateTime updatedAt;

  Owner({
    required this.id,
    required this.googleId,
    required this.name,
    required this.email,
    required this.emailVerifiedAt,
    required this.profilePicture,
    required this.isAdmin,
    required this.pinSetAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
    id: json["id"],
    googleId: json["google_id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    profilePicture: json["profile_picture"],
    isAdmin: json["is_admin"],
    pinSetAt: DateTime.parse(json["pin_set_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "google_id": googleId,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "profile_picture": profilePicture,
    "is_admin": isAdmin,
    "pin_set_at": pinSetAt.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
