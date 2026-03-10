class Usuario {
  final String name;
  final String email;
  final String phone;
  final String website;

  Usuario({
    required this.name,
    required this.email,
    required this.phone,
    required this.website,
  });

  // Convierte un mapa JSON en un objeto Usuario.
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      name:    json['name'],
      email:   json['email'],
      phone:   json['phone'],
      website: json['website'],
    );
  }
}
