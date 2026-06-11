class Contact {
  final int? id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? company;
  final String? notes;
  final String? avatarPath;
  final bool isFavorite;
  final DateTime createdAt;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.company,
    this.notes,
    this.avatarPath,
    this.isFavorite = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Contact copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? company,
    String? notes,
    String? avatarPath,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      company: company ?? this.company,
      notes: notes ?? this.notes,
      avatarPath: avatarPath ?? this.avatarPath,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'company': company,
      'notes': notes,
      'avatar_path': avatarPath,
      // SQLite has no boolean type — store as 1/0
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      address: map['address'] as String?,
      company: map['company'] as String?,
      notes: map['notes'] as String?,
      avatarPath: map['avatar_path'] as String?,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
