class Product {
  final String id;
  final String name;
  final double price;
  final DateTime updatedAt;
  final bool isSynced;
  final int version;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.updatedAt,
    this.isSynced = false,
    this.version = 1,
  });

  /// Create from JSON (API response)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: true,
      version: (json['version'] as num?)?.toInt() ?? 1,
    );
  }

  /// Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'updatedAt': updatedAt.toIso8601String(),
      'version': version,
    };
  }

  /// Create from SQLite row
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isSynced: (map['isSynced'] as int) == 1,
      version: (map['version'] as int?) ?? 1,
    );
  }

  /// Convert to SQLite map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
      'version': version,
    };
  }

  /// Create a copy with modified fields
  Product copyWith({
    String? id,
    String? name,
    double? price,
    DateTime? updatedAt,
    bool? isSynced,
    int? version,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      version: version ?? this.version,
    );
  }
}
