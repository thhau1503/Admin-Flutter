// post_model.dart
class Post {
  final String id;
  final String title;
  final String description;
  final int? price;
  final Location location;
  final Landlord landlord;
  final String roomType;
  final int? size;
  final bool availability;
  final Amenities amenities;
  final AdditionalCosts additionalCosts;
  final List<ImageModel> images;
  final List<VideoModel> videos;
  final double? averageRating;
  final int? views;
  final String status;
  final String createdAt;
  final String updatedAt;

  Post({
    required this.id,
    required this.title,
    required this.description,
    this.price,
    required this.location,
    required this.landlord,
    required this.roomType,
    this.size,
    required this.availability,
    required this.amenities,
    required this.additionalCosts,
    required this.images,
    required this.videos,
    this.averageRating,
    this.views,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'],
      location: Location.fromJson(json['location'] ?? {}),
      landlord: Landlord.fromJson(json['landlord'] ?? {}),
      roomType: json['roomType'] ?? '',
      size: json['size'],
      availability: json['availability'] ?? false,
      amenities: Amenities.fromJson(json['amenities'] ?? {}),
      additionalCosts: AdditionalCosts.fromJson(json['additionalCosts'] ?? {}),
      images: (json['images'] as List?)?.map((img) => ImageModel.fromJson(img)).toList() ?? [],
      videos: (json['videos'] as List?)?.map((vid) => VideoModel.fromJson(vid)).toList() ?? [],
      averageRating: json['averageRating']?.toDouble(),
      views: json['views'],
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class Location {
  final String address;
  final String city;
  final String district;
  final String ward;

  Location({
    required this.address,
    required this.city,
    required this.district,
    required this.ward,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      ward: json['ward'] ?? '',
    );
  }
}

class Landlord {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String address;

  Landlord({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory Landlord.fromJson(Map<String, dynamic> json) {
    return Landlord(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class Amenities {
  final bool hasWifi;
  final bool hasParking;
  final bool hasAirConditioner;
  final bool hasKitchen;
  final bool hasElevator;
  final List<String> others;

  Amenities({
    required this.hasWifi,
    required this.hasParking,
    required this.hasAirConditioner,
    required this.hasKitchen,
    required this.hasElevator,
    required this.others,
  });

  factory Amenities.fromJson(Map<String, dynamic> json) {
    return Amenities(
      hasWifi: json['hasWifi'] ?? false,
      hasParking: json['hasParking'] ?? false,
      hasAirConditioner: json['hasAirConditioner'] ?? false,
      hasKitchen: json['hasKitchen'] ?? false,
      hasElevator: json['hasElevator'] ?? false,
      others: List<String>.from(json['others'] ?? []),
    );
  }
}

class AdditionalCosts {
  final int? electricity;
  final int? water;
  final int? internet;
  final int? cleaningService;

  AdditionalCosts({
    this.electricity,
    this.water,
    this.internet,
    this.cleaningService,
  });

  factory AdditionalCosts.fromJson(Map<String, dynamic> json) {
    return AdditionalCosts(
      electricity: json['electricity'],
      water: json['water'],
      internet: json['internet'],
      cleaningService: json['cleaningService'],
    );
  }
}

class ImageModel {
  final String url;
  final String publicId;
  final String? id;

  ImageModel({
    required this.url,
    required this.publicId,
    this.id,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      url: json['url'] ?? '',
      publicId: json['public_id'] ?? '',
      id: json['_id'],
    );
  }
}

class VideoModel {
  final String url;
  final String publicId;
  final String? id;

  VideoModel({
    required this.url,
    required this.publicId,
    this.id,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      url: json['url'] ?? '',
      publicId: json['public_id'] ?? '',
      id: json['_id'],
    );
  }
}