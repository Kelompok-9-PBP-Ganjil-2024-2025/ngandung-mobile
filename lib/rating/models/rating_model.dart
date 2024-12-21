import 'dart:convert';

List<Rating> ratingFromJson(String str) =>
    List<Rating>.from(json.decode(str).map((x) => Rating.fromJson(x)));

String ratingToJson(List<Rating> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Rating {
  String model;
  int pk;
  Fields fields;

  Rating({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class Fields {
  int user;
  int rumahMakan;
  int rating;
  String review;
  DateTime tanggal;

  Fields({
    required this.user,
    required this.rumahMakan,
    required this.rating,
    required this.review,
    required this.tanggal,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        rumahMakan: json["rumah_makan"],
        rating: json["rating"],
        review: json["review"],
        tanggal: DateTime.parse(json["tanggal"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "rumah_makan": rumahMakan,
        "rating": rating,
        "review": review,
        "tanggal":
            "${tanggal.year.toString().padLeft(4, '0')}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}",
      };
}
