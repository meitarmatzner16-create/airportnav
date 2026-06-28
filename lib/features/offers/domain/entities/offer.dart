class Offer {
  final String id;
  final String title;
  final String merchant;
  final String description;
  final String discount;
  final String category;
  final String airportCode;
  final String? airline;
  final String? promoCode;
  final String imageUrl;
  final DateTime validFrom;
  final DateTime validUntil;
  final String termsAndConditions;

  const Offer({
    required this.id,
    required this.title,
    required this.merchant,
    required this.description,
    required this.discount,
    required this.category,
    required this.airportCode,
    this.airline,
    this.promoCode,
    required this.imageUrl,
    required this.validFrom,
    required this.validUntil,
    required this.termsAndConditions,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as String,
      title: json['title'] as String,
      merchant: json['merchant'] as String,
      description: json['description'] as String,
      discount: json['discount'] as String,
      category: json['category'] as String,
      airportCode: json['airportCode'] as String,
      airline: json['airline'] as String?,
      promoCode: json['promoCode'] as String?,
      imageUrl: json['imageUrl'] as String,
      validFrom: DateTime.parse(json['validFrom'] as String),
      validUntil: DateTime.parse(json['validUntil'] as String),
      termsAndConditions: json['termsAndConditions'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'merchant': merchant,
      'description': description,
      'discount': discount,
      'category': category,
      'airportCode': airportCode,
      'airline': airline,
      'promoCode': promoCode,
      'imageUrl': imageUrl,
      'validFrom': validFrom.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'termsAndConditions': termsAndConditions,
    };
  }

  bool get isValid => DateTime.now().isBefore(validUntil);
}
