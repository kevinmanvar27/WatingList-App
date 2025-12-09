class TermsOfService {
  bool success;
  Data data;

  TermsOfService({
    required this.success,
    required this.data,
  });

}

class Data {
  int id;
  String title;
  String slug;
  String content;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;

  Data({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

}
