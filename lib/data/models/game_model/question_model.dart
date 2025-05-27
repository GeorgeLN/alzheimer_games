
class QuestionModel {

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.level,
  });

  QuestionModel.fromJson(Map<String, dynamic> json)
  : this(
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      correctIndex: json['correct_index'] as int,
      level: json['level'] as int,
  );
  
  final String question;
  final List<String> options;
  final int correctIndex;
  final int level;

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'level': level,
    };
  }
}

