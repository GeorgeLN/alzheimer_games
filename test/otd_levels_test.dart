import 'package:flutter_test/flutter_test.dart';
import 'package:alzheimer_games_app/features/screens/games/OTD/otd_levels.dart';

void main() {
  group('OTD Levels', () {
    for (int i = 0; i < levels.length; i++) {
      test('Level ${i + 1} should be playable', () {
        final level = levels[i];
        final nodeConnections = <int, int>{};

        for (final node in level.nodes) {
          nodeConnections[level.nodes.indexOf(node)] = 0;
        }

        for (final line in level.lines) {
          nodeConnections[line.startNodeIndex] =
              (nodeConnections[line.startNodeIndex] ?? 0) + 1;
          nodeConnections[line.endNodeIndex] =
              (nodeConnections[line.endNodeIndex] ?? 0) + 1;
        }

        final oddDegreeNodes = nodeConnections.values.where((count) => count % 2 != 0).length;
        expect(oddDegreeNodes, lessThanOrEqualTo(2));
      });
    }
  });
}
