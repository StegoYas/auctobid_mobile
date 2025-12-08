class Item {
  final int id;
  final int userId;
  final int categoryId;
  final int conditionId;
  final String name;
  final String description;
  final double startingPrice;
  final double minimumBidIncrement;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? approvedAt;
  
  // Related models
  final String? userName;
  final String? categoryName;
  final String? conditionName;
  final List<ItemImage> images;
  
  Item({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.conditionId,
    required this.name,
    required this.description,
    required this.startingPrice,
    required this.minimumBidIncrement,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    this.approvedAt,
    this.userName,
    this.categoryName,
    this.conditionName,
    this.images = const [],
  });
  
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      conditionId: json['condition_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      startingPrice: (json['starting_price'] ?? 0).toDouble(),
      minimumBidIncrement: (json['minimum_bid_increment'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at']) : null,
      userName: json['user']?['name'],
      categoryName: json['category']?['name'],
      conditionName: json['condition']?['name'],
      images: (json['images'] as List<dynamic>?)
              ?.map((img) => ItemImage.fromJson(img))
              .toList() ?? [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'condition_id': conditionId,
      'name': name,
      'description': description,
      'starting_price': startingPrice,
      'minimum_bid_increment': minimumBidIncrement,
      'status': status,
      'rejection_reason': rejectionReason,
    };
  }
  
  String? get primaryImageUrl {
    final primary = images.firstWhere(
      (img) => img.isPrimary,
      orElse: () => images.isNotEmpty ? images.first : ItemImage.empty(),
    );
    return primary.imagePath;
  }
  
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isAuctioned => status == 'auctioned';
  bool get isSold => status == 'sold';
}

class ItemImage {
  final int id;
  final int itemId;
  final String imagePath;
  final String? thumbnailPath;
  final bool isPrimary;
  
  ItemImage({
    required this.id,
    required this.itemId,
    required this.imagePath,
    this.thumbnailPath,
    required this.isPrimary,
  });
  
  factory ItemImage.fromJson(Map<String, dynamic> json) {
    return ItemImage(
      id: json['id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      imagePath: json['image_path'] ?? '',
      thumbnailPath: json['thumbnail_path'],
      isPrimary: json['is_primary'] ?? false,
    );
  }
  
  factory ItemImage.empty() {
    return ItemImage(
      id: 0,
      itemId: 0,
      imagePath: '',
      isPrimary: false,
    );
  }
}

class Category {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  
  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
  });
  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      icon: json['icon'],
    );
  }
}

class Condition {
  final int id;
  final String name;
  final String? description;
  final int sortOrder;
  
  Condition({
    required this.id,
    required this.name,
    this.description,
    required this.sortOrder,
  });
  
  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}
