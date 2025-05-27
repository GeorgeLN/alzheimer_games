class PlayerModel {
  PlayerModel({
    this.scoreMemory,
    this.scorePuzzle,
    this.scoreTrivia,
    this.scorePattern,
    this.userName,
  });

  PlayerModel.fromJson(Map<String, Object?> json)
  : this(
      scoreMemory: json['score_memory'] as int?,
      scorePuzzle: json['score_puzzle'] as int?,
      scoreTrivia: json['score_trivia'] as int?,
      scorePattern: json['score_pattern'] as int?,
      userName: json['user_name'] as String?,
    );

  final int? scoreMemory;
  final int? scorePuzzle;
  final int? scoreTrivia;
  final int? scorePattern;
  final String? userName;

  // Factory to initialize all fields to 0
  factory PlayerModel.initial() {
    return PlayerModel(
      scoreMemory: 0,
      scorePuzzle: 0,
      scoreTrivia: 0,
      scorePattern: 0,
      userName: '',
    );
  }

  Map<String, Object?> toJson() {
    return {
      'score_memory': scoreMemory,
      'score_puzzle': scorePuzzle,
      'score_trivia': scoreTrivia,
      'score_pattern': scorePattern,
      'user_name': userName,
    };
  }
}