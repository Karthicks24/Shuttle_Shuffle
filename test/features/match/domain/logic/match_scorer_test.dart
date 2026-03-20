import 'package:flutter_test/flutter_test.dart';
import 'package:shuttle_shuffle/features/match/domain/entities/match.dart';
import 'package:shuttle_shuffle/features/match/domain/logic/match_scorer.dart';
import 'package:shuttle_shuffle/features/team/domain/entities/team.dart';

void main() {
  late MatchScorer matchScorer;
  late Team teamA;
  late Team teamB;
  late Match tMatch;

  setUp(() {
    matchScorer = MatchScorer();
    teamA = const Team(id: 't1', players: []);
    teamB = const Team(id: 't2', players: []);
    tMatch = Match(
      id: 'm1',
      teamA: teamA,
      teamB: teamB,
      maxPoints: 21,
    );
  });

  group('incrementScore', () {
    test('should increment scoreA', () {
      // act
      final result = matchScorer.incrementScoreA(tMatch);
      // assert
      expect(result.scoreA, 1);
      expect(result.scoreB, 0);
    });

    test('should increment scoreB', () {
      // act
      final result = matchScorer.incrementScoreB(tMatch);
      // assert
      expect(result.scoreB, 1);
      expect(result.scoreA, 0);
    });
  });

  group('win conditions', () {
    test('should finish match when teamA reaches maxPoints with 2 point lead', () {
      // arrange
      final match = tMatch.copyWith(scoreA: 20, scoreB: 18);
      // act
      final result = matchScorer.incrementScoreA(match);
      // assert
      expect(result.isFinished, true);
      expect(result.winner, teamA);
      expect(result.scoreA, 21);
    });

    test('should not finish match when teamA reaches maxPoints but lead is less than 2', () {
      // arrange
      final match = tMatch.copyWith(scoreA: 20, scoreB: 20);
      // act
      final result = matchScorer.incrementScoreA(match);
      // assert
      expect(result.isFinished, false);
      expect(result.scoreA, 21);
    });

    test('should finish match on deuce when 2 point lead is reached after maxPoints', () {
      // arrange
      final match = tMatch.copyWith(scoreA: 21, scoreB: 21);
      // act
      final result = matchScorer.incrementScoreA(match); // 22-21
      expect(result.isFinished, false);
      
      final finalResult = matchScorer.incrementScoreA(result); // 23-21
      // assert
      expect(finalResult.isFinished, true);
      expect(finalResult.winner, teamA);
      expect(finalResult.scoreA, 23);
    });

    test('should finish match when golden point cap is reached (30 points)', () {
      // arrange
      final match = tMatch.copyWith(scoreA: 29, scoreB: 29);
      // act
      final result = matchScorer.incrementScoreA(match);
      // assert
      expect(result.isFinished, true);
      expect(result.winner, teamA);
      expect(result.scoreA, 30);
    });
  });
}
