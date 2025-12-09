class Create_user {
  bool? success;
  Data? data;
  String? message;

  Create_user({this.success, this.data, this.message});

  Create_user.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  int? id;
  String? username;
  String? mobileNumber;
  int? totalUsersCount;
  AddedBy? addedBy;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
        this.username,
        this.mobileNumber,
        this.totalUsersCount,
        this.addedBy,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
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
