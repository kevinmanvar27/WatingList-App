class Restaurant_all_users {
  bool? success;
  List<Data5>? data;
  Meta? meta;
  String? message;

  Restaurant_all_users({this.success, this.data, this.meta, this.message});

  Restaurant_all_users.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data5>[];
      json['data'].forEach((v) {
        data!.add(new Data5.fromJson(v));
      });
    }
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.meta != null) {
      data['meta'] = this.meta!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data5 {
  int? id;
  String? username;
  String? mobileNumber;
  int? totalUsersCount;
  AddedBy? addedBy;
  String? createdAt;
  String? updatedAt;
  bool dineIn = false;

  Data5(
      {this.id,
        this.username,
        this.mobileNumber,
        this.totalUsersCount,
        this.addedBy,
        this.createdAt,
        this.updatedAt});

  Data5.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    mobileNumber = json['mobile_number'];
    totalUsersCount = json['total_users_count'];
    addedBy = json['added_by'] != null
        ? new AddedBy.fromJson(json['added_by'])
        : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['mobile_number'] = this.mobileNumber;
    data['total_users_count'] = this.totalUsersCount;
    if (this.addedBy != null) {
      data['added_by'] = this.addedBy!.toJson();
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class AddedBy {
  int? id;
  String? name;
  String? email;

  AddedBy({this.id, this.name, this.email});

  AddedBy.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    return data;
  }
}

class Meta {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Meta({this.currentPage, this.lastPage, this.perPage, this.total});

  Meta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    data['last_page'] = this.lastPage;
    data['per_page'] = this.perPage;
    data['total'] = this.total;
    return data;
  }
}
