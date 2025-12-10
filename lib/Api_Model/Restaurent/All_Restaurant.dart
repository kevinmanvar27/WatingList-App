import 'dart:convert';

AllRestaurant allRestaurantFromJson(String str) => AllRestaurant.fromJson(json.decode(str));

String allRestaurantToJson(AllRestaurant data) => json.encode(data.toJson());

class AllRestaurant {
  bool success;
  Data data;
  String message;

  AllRestaurant({
    required this.success,
    required this.data,
    required this.message,
  });

  factory AllRestaurant.fromJson(Map<String, dynamic> json) => AllRestaurant(
    success: json["success"],
    data: Data.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
    "message": message,
  };
}

class Data {
  int currentPage;
  List<Datum> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  List<Link> links;
  dynamic nextPageUrl;
  String path;
  int perPage;
  dynamic prevPageUrl;
  int to;
  int total;

  Data({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currentPage: json["current_page"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    firstPageUrl: json["first_page_url"],
    from: json["from"],
    lastPage: json["last_page"],
    lastPageUrl: json["last_page_url"],
    links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
    nextPageUrl: json["next_page_url"],
    path: json["path"],
    perPage: json["per_page"],
    prevPageUrl: json["prev_page_url"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "links": List<dynamic>.from(links.map((x) => x.toJson())),
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}

class Datum {
  int id;
  String? name;
  String? location;
  String? fullAddress;
  String? addressLine1;
  dynamic addressLine2;
  String? city;
  String? state;
  String? country;
  String? postalCode;
  String? contactNumber;
  String? profile;
  int? currentWaitingCount;
  dynamic distance;
  String? ownerName;
  dynamic description;
  String? isActive;
  int operationalStatus;
  double? latitude;  // Added latitude field
  double? longitude; // Added longitude field

  Datum({
    required this.id,
    this.name,
    this.location,
    this.fullAddress,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.contactNumber,
    this.profile,
    this.currentWaitingCount,
    this.distance,
    this.ownerName,
    this.description,
    this.isActive,
    required this.operationalStatus,
    this.latitude,   // Added latitude parameter
    this.longitude,  // Added longitude parameter
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
      id: json["id"] ?? 0,
      name: json["name"],
      location: json["location"],
      fullAddress: json["full_address"],
      addressLine1: json["address_line_1"],
      addressLine2: json["address_line_2"],
      city: json["city"],
      state: json["state"],
      country: json["country"],
      postalCode: json["postal_code"],
      contactNumber: json["contact_number"],
      profile: json["profile"],
      currentWaitingCount: json["current_waiting_count"],
      distance: json["distance"],
      ownerName: json["owner_name"],
      description: json["description"],
      isActive: json["is_active"],
      operationalStatus: json['operational_status'] ?? 0,
      latitude: json["latitude"] is num ? json["latitude"].toDouble() : null,   // Parse latitude
      longitude: json["longitude"] is num ? json["longitude"].toDouble() : null, // Parse longitude
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "location": location,
    "full_address": fullAddress,
    "address_line_1": addressLine1,
    "address_line_2": addressLine2,
    "city": city,
    "state": state,
    "country": country,
    "postal_code": postalCode,
    "contact_number": contactNumber,
    "profile": profile,
    "current_waiting_count": currentWaitingCount,
    "distance": distance,
    "owner_name": ownerName,
    "description": description,
    "is_active": isActive,
    'operational_status': operationalStatus,
    "latitude": latitude,    // Include latitude in JSON
    "longitude": longitude,  // Include longitude in JSON
  };
}

class Link {
  String? url;
  String label;
  bool active;

  Link({
    required this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
    url: json["url"],
    label: json["label"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "active": active,
  };
}