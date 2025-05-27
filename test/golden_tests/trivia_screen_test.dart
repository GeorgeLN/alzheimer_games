
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:alzheimer_games_app/features/screens/games/trivia/trivia_screen.dart';
import 'package:alzheimer_games_app/features/screens/games/trivia/trivia_view_model.dart';
import 'package:provider/provider.dart';

import '../mocks.dart';

void main() {
  final questionRepositoryMock = QuestionRepositoryMock();
  final authServiceMock = AuthServiceMock();
  final firestoreServiceMock = FirestoreServiceMock();

  deviceBuilder() => DeviceBuilder()
  ..overrideDevicesForAllScenarios(devices: [Device.iphone11])
  ..addScenario(widget: ChangeNotifierProvider(create: (context) => TriviaViewModel(questionRepository: questionRepositoryMock, authService: authServiceMock, firestoreService: firestoreServiceMock), child: TriviaScreen()));
  testGoldens(
    'TriviaScreen',
    (tester) async {
      await tester.pumpDeviceBuilder(deviceBuilder());
      await screenMatchesGolden(tester, 'trivia_screen');
    },
  );
}
