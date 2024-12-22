import 'dart:convert';

List<RumahMakan> rumahMakanFromJson(String str) =>
    List<RumahMakan>.from(json.decode(str).map((x) => RumahMakan.fromJson(x)));

String rumahMakanToJson(List<RumahMakan> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RumahMakan {
  String model;
  int pk;
  Fields fields;

  RumahMakan({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory RumahMakan.fromJson(Map<String, dynamic> json) => RumahMakan(
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
  int kodeProvinsi;
  String namaProvinsi;
  int bpsKodeKabupatenKota;
  String bpsNamaKabupatenKota;
  String namaRumahMakan;
  String alamat;
  String latitude;
  String longitude;
  int tahun;
  String masakanDariMana;
  String makananBeratRingan;
  String averageRating;
  int numberOfRatings;

  Fields({
    required this.kodeProvinsi,
    required this.namaProvinsi,
    required this.bpsKodeKabupatenKota,
    required this.bpsNamaKabupatenKota,
    required this.namaRumahMakan,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    required this.tahun,
    required this.masakanDariMana,
    required this.makananBeratRingan,
    required this.averageRating,
    required this.numberOfRatings,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        kodeProvinsi: json["kode_provinsi"],
        namaProvinsi: json["nama_provinsi"],
        bpsKodeKabupatenKota: json["bps_kode_kabupaten_kota"],
        bpsNamaKabupatenKota: json["bps_nama_kabupaten_kota"],
        namaRumahMakan: json["nama_rumah_makan"],
        alamat: json["alamat"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        tahun: json["tahun"],
        masakanDariMana: json["masakan_dari_mana"],
        makananBeratRingan: json["makanan_berat_ringan"],
        averageRating: json["average_rating"],
        numberOfRatings: json["number_of_ratings"],
      );

  Map<String, dynamic> toJson() => {
        "kode_provinsi": kodeProvinsi,
        "nama_provinsi": namaProvinsi,
        "bps_kode_kabupaten_kota": bpsKodeKabupatenKota,
        "bps_nama_kabupaten_kota": bpsNamaKabupatenKota,
        "nama_rumah_makan": namaRumahMakan,
        "alamat": alamat,
        "latitude": latitude,
        "longitude": longitude,
        "tahun": tahun,
        "masakan_dari_mana": masakanDariMana,
        "makanan_berat_ringan": makananBeratRingan,
        "average_rating": averageRating,
        "number_of_ratings": numberOfRatings,
      };
}
