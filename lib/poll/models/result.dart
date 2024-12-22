class Poll {
  final String author;
  final String question;
  final List<Choice> choices;

  Poll({required this.author, required this.question, required this.choices});

  // Convert JSON to Poll model
  factory Poll.fromJson(Map<String, dynamic> json) {
    var choicesList = (json['choices'] as List)
        .map((choiceJson) => Choice.fromJson(choiceJson))
        .toList();

    return Poll(
      author: json['author'],
      question: json['poll'],
      choices: choicesList,
    );
  }

  int get totalVotes {
    return choices.fold(0, (sum, choice) => sum + choice.voteCount);
  }
}

class Choice {
  final String choiceText;
  final int voteCount;

  Choice({required this.choiceText, required this.voteCount});

  // Convert JSON to Choice model
  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      choiceText: json['choice_text'],
      voteCount: json['vote_count'],
    );
  }
}
