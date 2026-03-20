import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shuttle_shuffle/core/error/failures.dart';
import 'package:shuttle_shuffle/features/player/data/datasources/player_local_data_source.dart';
import 'package:shuttle_shuffle/features/player/data/models/player_model.dart';
import 'package:shuttle_shuffle/features/player/data/repositories/player_repository_impl.dart';
import 'package:shuttle_shuffle/features/player/domain/entities/player.dart';

class MockPlayerLocalDataSource extends Mock implements PlayerLocalDataSource {}

void main() {
  late PlayerRepositoryImpl repository;
  late MockPlayerLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockPlayerLocalDataSource();
    repository = PlayerRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  const tPlayer = Player(id: '1', name: 'Test Player');
  final tPlayerModel = PlayerModel.fromEntity(tPlayer);
  const tPlayerId = '1';

  group('addPlayer', () {
    test('should call addPlayer on local data source', () async {
      // arrange
      when(() => mockLocalDataSource.addPlayer(any()))
          .thenAnswer((_) async => Future.value());
      // act
      final result = await repository.addPlayer(tPlayer);
      // assert
      verify(() => mockLocalDataSource.addPlayer(tPlayerModel));
      expect(result, const Right(null));
    });

    test('should return CacheFailure when local data source throws an exception', () async {
      // arrange
      when(() => mockLocalDataSource.addPlayer(any()))
          .thenThrow(Exception());
      // act
      final result = await repository.addPlayer(tPlayer);
      // assert
      expect(result, Left(CacheFailure()));
    });
  });

  group('deletePlayer', () {
    test('should call deletePlayer on local data source', () async {
      // arrange
      when(() => mockLocalDataSource.deletePlayer(any()))
          .thenAnswer((_) async => Future.value());
      // act
      final result = await repository.deletePlayer(tPlayerId);
      // assert
      verify(() => mockLocalDataSource.deletePlayer(tPlayerId));
      expect(result, const Right(null));
    });

    test('should return CacheFailure when local data source throws an exception', () async {
      // arrange
      when(() => mockLocalDataSource.deletePlayer(any()))
          .thenThrow(Exception());
      // act
      final result = await repository.deletePlayer(tPlayerId);
      // assert
      expect(result, Left(CacheFailure()));
    });
  });

  group('getPlayers', () {
    final tPlayerModelList = [tPlayerModel];
    final tPlayerList = [tPlayer];

    test('should return list of players from local data source', () async {
      // arrange
      when(() => mockLocalDataSource.getPlayers())
          .thenAnswer((_) async => tPlayerModelList);
      // act
      final result = await repository.getPlayers();
      // assert
      verify(() => mockLocalDataSource.getPlayers());
      final players = result.getOrElse(() => throw Exception('Failed to get players'));
      expect(players, tPlayerList);
    });

    test('should return CacheFailure when local data source throws an exception', () async {
      // arrange
      when(() => mockLocalDataSource.getPlayers())
          .thenThrow(Exception());
      // act
      final result = await repository.getPlayers();
      // assert
      expect(result, Left(CacheFailure()));
    });
  });

  setUpAll(() {
    registerFallbackValue(tPlayerModel);
  });
}
