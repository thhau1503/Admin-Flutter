import 'package:admin/models/user_model.dart';

class Report {
  final String id;
  final User id_user;
  final PostDto id_post;
  final String report_reason;
  final String description;
  final String status;
  final String createdAt;
  final String updatedAt;
  Report.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        id_user = User.fromJsonCustom(json['id_user']),
        id_post = PostDto.fromJson(json['id_post']),
        report_reason = json['report_reason'],
        description = json['description'],
        status = json['status'],
        createdAt = json['createdAt'],
        updatedAt = json['updatedAt'];
}

class PostDto {
  final String id;
  final String title;
  final String description;
  final int price;
  final Location location;
  final dynamic averageRating; // Đổi từ String sang dynamic
  final int views;

  PostDto.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        title = json['title'],
        description = json['description'],
        price = json['price'],
        location = Location.fromJson(json['location']),
        averageRating = json['averageRating']?.toString(), // Chuyển sang String
        views = json['views'];
}

class Location {
  final String address;
  final String city;
  final String district;
  final String ward;
  final GeoLocation geoLocation;

  Location({
    required this.address,
    required this.city,
    required this.district,
    required this.ward,
    required this.geoLocation,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'],
      city: json['city'],
      district: json['district'],
      ward: json['ward'],
      geoLocation: GeoLocation.fromJson(json['geoLocation']),
    );
  }
}

class GeoLocation {
  final String type;
  final List<double> coordinates;

  GeoLocation({
    required this.type,
    required this.coordinates,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    // Xử lý `coordinates` để đảm bảo không có giá trị null
    final List<dynamic> rawCoordinates = json['coordinates'];
    final List parsedCoordinates = rawCoordinates.map((e) {
      return e != null ? e.toDouble() : 0.0;
    }).toList();

    return GeoLocation(
      type: json['type'],
      coordinates: parsedCoordinates.cast<double>(), //+
    );
  }
}
