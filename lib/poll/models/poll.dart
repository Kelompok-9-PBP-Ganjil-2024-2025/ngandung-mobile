import 'dart:convert';

Poll pollFromJson(String str) => Poll.fromJson(json.decode(str));

String pollToJson(Poll data) => json.encode(data.toJson());

class Poll {
  String id;
  String author;
  String question;
  bool isActive;
  bool viewResults;

  Poll({
    required this.id,
    required this.author,
    required this.question,
    required this.isActive,
    this.viewResults = true,
  });

  factory Poll.fromJson(Map<String, dynamic> json) => Poll(
    id: json["id"],
    author: json["author"],
    question: json["question"],
    isActive: json["is_active"],
    viewResults: json["view_results"] ?? true,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "author": author,
    "question": question,
    "is_active": isActive,
    "view_results": viewResults,
  };
}