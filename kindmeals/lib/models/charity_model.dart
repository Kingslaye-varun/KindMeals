class CharityModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<double> recommendedAmounts;
  final String? websiteUrl;
  final String? address;
  final String? contactPhone;
  final String? contactEmail;

  CharityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.recommendedAmounts,
    this.websiteUrl,
    this.address,
    this.contactPhone,
    this.contactEmail,
  });

  factory CharityModel.fromJson(Map<String, dynamic> json) {
    List<double> amounts = [];
    if (json['recommendedAmounts'] != null) {
      if (json['recommendedAmounts'] is List) {
        for (var amount in json['recommendedAmounts']) {
          amounts.add(amount is double ? amount : amount.toDouble());
        }
      }
    }

    if (amounts.isEmpty) {
      amounts = [100.0, 500.0, 1000.0, 5000.0]; // Default amounts
    }

    return CharityModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      recommendedAmounts: amounts,
      websiteUrl: json['websiteUrl'],
      address: json['address'],
      contactPhone: json['contactPhone'],
      contactEmail: json['contactEmail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'recommendedAmounts': recommendedAmounts,
      'websiteUrl': websiteUrl,
      'address': address,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
    };
  }
}
