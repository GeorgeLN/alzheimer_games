class CardModel {

  CardModel({
    required this.value,
    this.isFlipped = false,
    this.isMatched = false,
  });

  final int value;
  bool isFlipped;
  bool isMatched;
}