class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String role;
  final String status;
  final String? profilePhotoUrl;
  final String? identityPhotoUrl;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.role,
    required this.status,
    this.profilePhotoUrl,
    this.identityPhotoUrl,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      role: json['role'] ?? 'masyarakat',
      status: json['status'] ?? 'pending',
      profilePhotoUrl: json['profile_photo_url'],
      identityPhotoUrl: json['identity_photo_url'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'status': status,
    };
  }

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isSuspended => status == 'suspended';
  
  // Aliases for photo URLs
  String? get profilePhoto => profilePhotoUrl;
  String? get identityPhoto => identityPhotoUrl;
}
