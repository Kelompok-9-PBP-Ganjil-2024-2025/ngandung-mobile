import 'dart:convert';

List<Forum> forumFromJson(String str) => List<Forum>.from(json.decode(str).map((x) => Forum.fromJson(x)));

String forumToJson(List<Forum> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Forum {
    String model;
    String pk;
    Fields fields;

    Forum({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Forum.fromJson(Map<String, dynamic> json) => Forum(
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
    String title;
    String content;
    DateTime dateCreated;
    DateTime lastUpdated;

    Fields({
        required this.user,
        required this.title,
        required this.content,
        required this.dateCreated,
        required this.lastUpdated,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        title: json["title"],
        content: json["content"],
        dateCreated: DateTime.parse(json["date_created"]),
        lastUpdated: DateTime.parse(json["last_updated"]),
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "title": title,
        "content": content,
        "date_created": dateCreated.toIso8601String(),
        "last_updated": lastUpdated.toIso8601String(),
    };
}