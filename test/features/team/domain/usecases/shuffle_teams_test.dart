import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:shuttle_shuffle/core/error/failures.dart';
import 'package:shuttle_shuffle/features/player/domain/entities/player.dart';
import 'package:shuttle_shuffle/features/team/domain/entities/team.dart';
import 'package:shuttle_shuffle/features/team/domain/usecases/shuffle_teams.dart';
import 'package:flutter/foundation.dart';

void main() {
  late ShuffleTeams usecase;

  setUp(() {
    usecase = ShuffleTeams();
  });

  const tPlayers = [
    Player(id: '1', name: 'Player 1'),
    Player(id: '2', name: 'Player 2'),
    Player(id: '3', name: 'Player 3'),
    Player(id: '4', name: 'Player 4'),
  ];

  test('should return an empty list when input players list is empty', () async {
    // act
    final result = await usecase([]);
    // assert
    expect(result, const Right<Failure, List<Team>>([]));
  });

  test('should create 2 teams of 2 when 4 players are provided', () async {
    // act
    final result = await usecase(tPlayers);
    // assert
    final teams = result.getOrElse(() => throw Exception('Failed to shuffle'));
    expect(teams.length, 2);
    expect(teams[0].players.length, 2);
    expect(teams[1].players.length, 2);
    
    // Check all players are present
    final allPlayersInTeams = teams.expand((t) => t.players).toList();
    expect(allPlayersInTeams.length, 4);
    expect(allPlayersInTeams, containsAll(tPlayers));
  });

  test('should create 1 team of 2 and 1 team of 1 when 3 players are provided', () async {
    // arrange
    final players = tPlayers.sublist(0, 3);
    // act
    final result = await usecase(players);
    // assert
    final teams = result.getOrElse(() => throw Exception('Failed to shuffle'));
    expect(teams.length, 2);
    expect(teams[0].players.length, 2);
    expect(teams[1].players.length, 1);
    
    final allPlayersInTeams = teams.expand((t) => t.players).toList();
    expect(allPlayersInTeams.length, 3);
    expect(allPlayersInTeams, containsAll(players));
  });

  test('should shuffle players (probabilistic)', () async {
    // This test might occasionally fail if the shuffle results in the same order,
    // but with 4 players, there are 24 permutations.
    // To be safer, we can try multiple times if it matches the first time.
    
    bool shuffled = false;
    for (int i = 0; i < 10; i++) {
      final result = await usecase(tPlayers);
      final teams = result.getOrElse(() => throw Exception('Failed to shuffle'));
      final orderedPlayers = teams.expand((t) => t.players).toList();
      
      if (!listEquals(orderedPlayers, tPlayers)) {
        shuffled = true;
        break;
      }
    }
    expect(shuffled, true);
  });
}
