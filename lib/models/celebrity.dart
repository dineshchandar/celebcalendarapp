class Celebrity {
  final String name;
  final DateTime birthDate;
  final String imageUrl;

  Celebrity({
    required this.name,
    required this.birthDate,
    required this.imageUrl,
  });

  factory Celebrity.fromJson(Map<String, dynamic> json) {
    return Celebrity(
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'birthDate': birthDate.toIso8601String(),
    'imageUrl': imageUrl,
  };
}
