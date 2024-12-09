import 'package:uuid/uuid.dart';

class Poll {
  final String id;
  final String authorUsername;
  final String question;
  final bool isActive;
  final List<Choice> choices;

  Poll({
    required this.id,
    required this.authorUsername,
    required this.question,
    required this.isActive,
    required this.choices,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'] ?? const Uuid().v4(),
      authorUsername: json['author'] ?? '',
      question: json['question'] ?? '',
      isActive: json['is_active'] ?? true,
      choices: (json['choices'] as List?)
          ?.map((choice) => Choice.fromJson(choice))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': authorUsername,
    'question': question,
    'is_active': isActive,
    'choices': choices.map((choice) => choice.toJson()).toList(),
  };
}

class Choice {
  final String id;
  final String pollId;
  final String choiceText;
  final int voteCount;

  Choice({
    required this.id,
    required this.pollId,
    required this.choiceText,
    required this.voteCount,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['id'] ?? const Uuid().v4(),
      pollId: json['poll'] ?? '',
      choiceText: json['choice_text'] ?? '',
      voteCount: json['vote_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'poll': pollId,
    'choice_text': choiceText,
    'vote_count': voteCount,
  };
}