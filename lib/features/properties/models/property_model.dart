class Property {
  final int? id;
  final String title;
  final String? description;
  final double price;
  final String propertyType;
  final String address;
  final String city;
  final String state;
  final int? bedrooms;
  final int? bathrooms;
  final double? area;
  final List<String> imagePaths;
  final int userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Property({
    this.id,
    required this.title,
    this.description,
    required this.price,
    required this.propertyType,
    required this.address,
    required this.city,
    required this.state,
    this.bedrooms,
    this.bathrooms,
    this.area,
    this.imagePaths = const [],
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      price: (map['price'] as num).toDouble(),
      propertyType: map['property_type'] as String,
      address: map['address'] as String,
      city: map['city'] as String,
      state: map['state'] as String,
      bedrooms: map['bedrooms'] as int?,
      bathrooms: map['bathrooms'] as int?,
      area: map['area'] != null ? (map['area'] as num).toDouble() : null,
      imagePaths: _parseImagePaths(map),
      userId: map['user_id'] as int,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'property_type': propertyType,
      'address': address,
      'city': city,
      'state': state,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'image_paths': imagePaths.join(','),
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Property copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    String? propertyType,
    String? address,
    String? city,
    String? state,
    int? bedrooms,
    int? bathrooms,
    double? area,
    List<String>? imagePaths,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      propertyType: propertyType ?? this.propertyType,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      area: area ?? this.area,
      imagePaths: imagePaths ?? this.imagePaths,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getter de compatibilidad hacia atrás
  String? get imagePath => imagePaths.isNotEmpty ? imagePaths.first : null;

  String get formattedPrice {
    return '\$${price.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String get propertyTypeDisplayName {
    switch (propertyType.toLowerCase()) {
      case 'house':
        return 'Casa';
      case 'apartment':
        return 'Apartamento';
      case 'condo':
        return 'Condominio';
      case 'townhouse':
        return 'Casa adosada';
      case 'land':
        return 'Terreno';
      case 'commercial':
        return 'Comercial';
      default:
        return propertyType;
    }
  }

  @override
  String toString() {
    return 'Property(id: $id, title: $title, price: $price, type: $propertyType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Property &&
        other.id == id &&
        other.title == title &&
        other.price == price;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, price);
  }

  // Método helper para parsear paths de imagen (compatibilidad hacia atrás)
  static List<String> _parseImagePaths(Map<String, dynamic> map) {
    // Priorizar el nuevo campo image_paths
    if (map['image_paths'] != null) {
      return (map['image_paths'] as String)
          .split(',')
          .where((path) => path.isNotEmpty)
          .toList();
    }
    // Fallback al campo viejo image_path
    else if (map['image_path'] != null) {
      final String path = map['image_path'] as String;
      return path.isNotEmpty ? [path] : [];
    }
    return [];
  }
}
