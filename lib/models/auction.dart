class Auction {
  final int id;
  final String status;
  final double currentPrice;
  final String formattedPrice;
  final int totalBids;
  final DateTime startTime;
  final DateTime endTime;
  final String? timeRemaining;
  final bool isActive;
  final AuctionItem? item;
  final List<AuctionBid>? bids;
  final AuctionWinner? winner;
  final double? finalPrice;
  final String? formattedFinalPrice;

  Auction({
    required this.id,
    required this.status,
    required this.currentPrice,
    required this.formattedPrice,
    required this.totalBids,
    required this.startTime,
    required this.endTime,
    this.timeRemaining,
    required this.isActive,
    this.item,
    this.bids,
    this.winner,
    this.finalPrice,
    this.formattedFinalPrice,
  });

  factory Auction.fromJson(Map<String, dynamic> json) {
    return Auction(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'active',
      currentPrice: (json['current_price'] ?? 0).toDouble(),
      formattedPrice: json['formatted_price'] ?? 'Rp 0',
      totalBids: json['total_bids'] ?? 0,
      startTime: DateTime.parse(json['start_time'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['end_time'] ?? DateTime.now().toIso8601String()),
      timeRemaining: json['time_remaining'],
      isActive: json['is_active'] ?? false,
      item: json['item'] != null ? AuctionItem.fromJson(json['item']) : null,
      bids: json['bids'] != null 
          ? (json['bids'] as List).map((b) => AuctionBid.fromJson(b)).toList()
          : null,
      winner: json['winner'] != null ? AuctionWinner.fromJson(json['winner']) : null,
      finalPrice: json['final_price']?.toDouble(),
      formattedFinalPrice: json['formatted_final_price'],
    );
  }
}

class AuctionItem {
  final int id;
  final String name;
  final String description;
  final double startingPrice;
  final double minimumBidIncrement;
  final AuctionCategory? category;
  final AuctionCondition? condition;
  final String? primaryImage;
  final List<AuctionImage>? images;
  final AuctionOwner? owner;

  AuctionItem({
    required this.id,
    required this.name,
    required this.description,
    required this.startingPrice,
    required this.minimumBidIncrement,
    this.category,
    this.condition,
    this.primaryImage,
    this.images,
    this.owner,
  });

  factory AuctionItem.fromJson(Map<String, dynamic> json) {
    return AuctionItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      startingPrice: (json['starting_price'] ?? 0).toDouble(),
      minimumBidIncrement: (json['minimum_bid_increment'] ?? 10000).toDouble(),
      category: json['category'] != null ? AuctionCategory.fromJson(json['category']) : null,
      condition: json['condition'] != null ? AuctionCondition.fromJson(json['condition']) : null,
      primaryImage: json['primary_image'],
      images: json['images'] != null
          ? (json['images'] as List).map((i) => AuctionImage.fromJson(i)).toList()
          : null,
      owner: json['owner'] != null ? AuctionOwner.fromJson(json['owner']) : null,
    );
  }
}

class AuctionCategory {
  final int id;
  final String name;

  AuctionCategory({required this.id, required this.name});

  factory AuctionCategory.fromJson(Map<String, dynamic> json) {
    return AuctionCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class AuctionCondition {
  final int id;
  final String name;
  final int qualityRating;

  AuctionCondition({required this.id, required this.name, required this.qualityRating});

  factory AuctionCondition.fromJson(Map<String, dynamic> json) {
    return AuctionCondition(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      qualityRating: json['quality_rating'] ?? 5,
    );
  }
}

class AuctionImage {
  final int id;
  final String url;
  final String thumbnailUrl;
  final bool isPrimary;

  AuctionImage({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.isPrimary,
  });

  factory AuctionImage.fromJson(Map<String, dynamic> json) {
    return AuctionImage(
      id: json['id'] ?? 0,
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? json['url'] ?? '',
      isPrimary: json['is_primary'] ?? false,
    );
  }
}

class AuctionOwner {
  final int id;
  final String name;

  AuctionOwner({required this.id, required this.name});

  factory AuctionOwner.fromJson(Map<String, dynamic> json) {
    return AuctionOwner(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class AuctionBid {
  final int id;
  final double amount;
  final String formattedAmount;
  final AuctionOwner user;
  final bool isWinning;
  final DateTime createdAt;

  AuctionBid({
    required this.id,
    required this.amount,
    required this.formattedAmount,
    required this.user,
    this.isWinning = false,
    required this.createdAt,
  });

  factory AuctionBid.fromJson(Map<String, dynamic> json) {
    return AuctionBid(
      id: json['id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      formattedAmount: json['formatted_amount'] ?? 'Rp 0',
      user: AuctionOwner.fromJson(json['user'] ?? {'id': 0, 'name': 'Unknown'}),
      isWinning: json['is_winning'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class AuctionWinner {
  final int id;
  final String name;

  AuctionWinner({required this.id, required this.name});

  factory AuctionWinner.fromJson(Map<String, dynamic> json) {
    return AuctionWinner(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
