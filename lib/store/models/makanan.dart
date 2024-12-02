// To parse this JSON data, do
//
//     final makanan = makananFromJson(jsonString);

import 'dart:convert';

List<Makanan> makananFromJson(String str) => List<Makanan>.from(json.decode(str).map((x) => Makanan.fromJson(x)));

String makananToJson(List<Makanan> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Makanan {
    String model;
    int pk;
    Fields fields;

    Makanan({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Makanan.fromJson(Map<String, dynamic> json) => Makanan(
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
    String name;
    int price;
    int rumahMakan;

    Fields({
        required this.name,
        required this.price,
        required this.rumahMakan,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        name: json["name"],
        price: json["price"],
        rumahMakan: json["rumah_makan"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "price": price,
        "rumah_makan": rumahMakan,
    };
}
