/// Entity to hold location information
class LocationData {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String country;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.country,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'city': city,
        'country': country,
      };

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
        latitude: json['latitude'] as double,
        longitude: json['longitude'] as double,
        address: json['address'] as String,
        city: json['city'] as String,
        country: json['country'] as String,
      );
}