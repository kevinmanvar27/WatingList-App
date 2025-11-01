class Restaurant {
  final int? id;
  final String name;
  final String state;

  Restaurant({this.id, required this.name, required this.state});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'state': state,
  };

  factory Restaurant.fromMap(Map<String, dynamic> map) => Restaurant(
    id: map['id'] as int?,
    name: map['name'] as String,
    state: map['state'] as String,
  );
}
