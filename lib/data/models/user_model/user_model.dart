class PlayerModel {
  PlayerModel({
    this.scoreMemory,
    this.scorePuzzle,
    this.scoreTrivia,
    this.scorePattern,
    this.scoreOtd,
    this.userName,
    this.userId,
    this.completedLevels,
  });

  PlayerModel.fromJson(Map<String, Object?> json)
      : this(
          scoreMemory: json['score_memory'] as int?,
          scorePuzzle: json['score_puzzle'] as int?,
          scoreTrivia: json['score_trivia'] as int?,
          scorePattern: json['score_pattern'] as int?,
          scoreOtd: json['score_otd'] as int?,
          userName: json['user_name'] as String?,
          userId: json['userId'] as String?,
          completedLevels:
              (json['completed_levels'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as List<dynamic>).cast<int>()),
          ),
        );

  final int? scoreMemory;
  final int? scorePuzzle;
  late final int? scoreTrivia;
  final int? scorePattern;
  final int? scoreOtd;
  final String? userName;
  final String? userId;
  final Map<String, List<int>>? completedLevels;

  // Factory to initialize all fields to 0
  factory PlayerModel.initial(
      {required String userId, required String userName}) {
    return PlayerModel(
      scoreMemory: 0,
      scorePuzzle: 0,
      scoreTrivia: 0,
      scorePattern: 0,
      scoreOtd: 0,
      userName: userName,
      userId: userId,
      completedLevels: {},
    );
  }

  Map<String, Object?> toJson() {
    return {
      'score_memory': scoreMemory,
      'score_puzzle': scorePuzzle,
      'score_trivia': scoreTrivia,
      'score_pattern': scorePattern,
      'score_otd': scoreOtd,
      'user_name': userName,
      'userId': userId,
      'completed_levels': completedLevels,
    };
  }
}