import 'dart:convert';

/// Fungsi utama untuk konversi dari JSON ke List<Comment>:
List<Comment> commentFromJson(String str) =>
    List<Comment>.from(json.decode(str).map((x) => Comment.fromJson(x)));

/// Fungsi utama untuk konversi dari List<Comment> ke JSON:
String commentToJson(List<Comment> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

/// Kelas utama 'Comment' yang merepresentasikan tiap item dalam JSON
class Comment {
  Comment({
    required this.model,
    required this.pk,
    required this.fields,
  });

  final String model;
  final String pk;
  final CommentFields fields;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        model: json["model"],
        pk: json["pk"],
        fields: CommentFields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
      };
}

/// Kelas 'CommentFields' merepresentasikan atribut detail pada 'fields'
class CommentFields {
  CommentFields({
    required this.discussion,
    required this.user,
    required this.content,
    this.parent,           // parent bisa null
    required this.dateCreated,
    required this.likes,   // likes adalah list user_id yang menyukai komentar
  });

  final String discussion;
  final int user;
  final String content;
  final String? parent;
  final DateTime dateCreated;
  final List<int> likes;

  factory CommentFields.fromJson(Map<String, dynamic> json) => CommentFields(
        discussion: json["discussion"],    // UUID dari Discussion
        user: json["user"],               // user_id
        content: json["content"],
        parent: json["parent"],           // bisa null, maka jadi String? 
        dateCreated: DateTime.parse(json["date_created"]),
        likes: List<int>.from(json["likes"].map((x) => x)), 
      );

  Map<String, dynamic> toJson() => {
        "discussion": discussion,
        "user": user,
        "content": content,
        "parent": parent,
        "date_created": dateCreated.toIso8601String(),
        "likes": List<dynamic>.from(likes.map((x) => x)),
      };
}
