import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shuttle_shuffle/core/usecases/usecase.dart';
import 'package:shuttle_shuffle/features/player/domain/entities/player.dart';
import 'package:shuttle_shuffle/features/player/domain/repositories/player_repository.dart';
import 'package:shuttle_shuffle/features/player/domain/usecases/add_player.dart';
import 'package:shuttle_shuffle/features/player/domain/usecases/delete_player.dart';
import 'package:shuttle_shuffle/features/player/domain/usecases/get_players.dart';

class MockPlayerRepository extends Mock implements PlayerRepository {}

void main() {
  late MockPlayerRepository mockRepository;
  late AddPlayer addPlayer;
  late DeletePlayer deletePlayer;
  late GetPlayers getPlayers;

  setUp(() {
    mockRepository = MockPlayerRepository();
    addPlayer = AddPlayer(mockRepository);
    deletePlayer = DeletePlayer(mockRepository);
    getPlayers = GetPlayers(mockRepository);
  });

  const tPlayer = Player(id: '1', name: 'Test Player');
  const tPlayerId = '1';

  group('AddPlayer', () {
    test('should call addPlayer on the repository', () async {
      // arrange
      when(() => mockRepository.addPlayer(any()))
          .thenAnswer((_) async => const Right(null));
      // act
      final result = await addPlayer(tPlayer);
      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.addPlayer(tPlayer));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('DeletePlayer', () {
    test('should call deletePlayer on the repository', () async {
      // arrange
      when(() => mockRepository.deletePlayer(any()))
          .thenAnswer((_) async => const Right(null));
      // act
      final result = await deletePlayer(tPlayerId);
      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.deletePlayer(tPlayerId));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('GetPlayers', () {
    final tPlayersList = [tPlayer];
    test('should call getPlayers on the repository', () async {
      // arrange
      when(() => mockRepository.getPlayers())
          .thenAnswer((_) async => Right(tPlayersList));
      // act
      final result = await getPlayers(NoParams());
      // assert
      expect(result, Right(tPlayersList));
      verify(() => mockRepository.getPlayers());
      verifyNoMoreInteractions(mockRepository);
    });
  });

  setUpAll(() {
    registerFallbackValue(tPlayer);
  });
}
