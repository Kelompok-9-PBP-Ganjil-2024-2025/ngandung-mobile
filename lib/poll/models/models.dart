import 'package:uuid/uuid.dart';

class Poll {
  final String id;
  final String authorId;
  final String question;
  final bool isActive;
  List<Choice> choices;

  Poll({
    required this.id,
    required this.authorId,
    required this.question,
    this.isActive = true,
    this.choices = const [],
  });

  factory Poll.create(String authorId, String question) {
    return Poll(
      id: Uuid().v4(),
      authorId: authorId,
      question: question,
    );
  }

  @override
  String toString() => question;
}

class Choice {
  final String id;
  final String pollId;
  final String choiceText;
  int voteCount;

  Choice({
    required this.id,
    required this.pollId,
    required this.choiceText,
    this.voteCount = 0,
  });

  factory Choice.create(String pollId, String choiceText) {
    return Choice(
      id: Uuid().v4(),
      pollId: pollId,
      choiceText: choiceText,
    );
  }

  @override
  String toString() => choiceText;
}

class Vote {
  final String id;
  final String pollId;
  final String choiceId;
  final String userId;

  Vote({
    required this.id,
    required this.pollId,
    required this.choiceId,
    required this.userId,
  });

  factory Vote.create(String pollId, String choiceId, String userId) {
    return Vote(
      id: Uuid().v4(),
      pollId: pollId,
      choiceId: choiceId,
      userId: userId,
    );
  }

  @override
  String toString() => 'User $userId voted for choice $choiceId';
}
