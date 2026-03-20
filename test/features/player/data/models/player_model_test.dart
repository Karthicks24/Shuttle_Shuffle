import 'package:flutter_test/flutter_test.dart';
import 'package:shuttle_shuffle/features/player/data/models/player_model.dart';
import 'package:shuttle_shuffle/features/player/domain/entities/player.dart';

void main() {
  const tPlayerModel = PlayerModel(id: '1', name: 'Test Player');

  test('should be a subclass of Player entity', () async {
    // assert
    expect(tPlayerModel, isA<Player>());
  });

  group('fromEntity', () {
    test('should return a valid model from Player entity', () {
      // arrange
      const tPlayer = Player(id: '1', name: 'Test Player');
      // act
      final result = PlayerModel.fromEntity(tPlayer);
      // assert
      expect(result.id, tPlayer.id);
      expect(result.name, tPlayer.name);
    });
  });
}
