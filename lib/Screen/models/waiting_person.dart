class WaitingPerson {
  final int? id;
  final int restaurantId;
  final String name;
  final int partySize;

  WaitingPerson({
    this.id,
    required this.restaurantId,
    required this.name,
    required this.partySize,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'restaurantId': restaurantId,
    'name': name,
    'partySize': partySize,
  };

  factory WaitingPerson.fromMap(Map<String, dynamic> map) => WaitingPerson(
    id: map['id'] as int?,
    restaurantId: map['restaurantId'] as int,
    name: map['name'] as String,
    partySize: map['partySize'] as int,
  );
}
