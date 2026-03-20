import 'package:flutter_test/flutter_test.dart';
import 'package:shuttle_shuffle/features/team/domain/entities/team.dart';
import 'package:shuttle_shuffle/features/tournament/domain/usecases/generate_fixtures.dart';

void main() {
  late GenerateFixtures usecase;

  setUp(() {
    usecase = GenerateFixtures();
  });

  const tTeams = [
    Team(id: '1', players: []),
    Team(id: '2', players: []),
    Team(id: '3', players: []),
    Team(id: '4', players: []),
  ];

  group('generateRoundRobin', () {
    test('should return empty list when less than 2 teams are provided', () {
      final result = usecase.generateRoundRobin([tTeams[0]], 21);
      expect(result, []);
    });

    test('should return 6 matches for 4 teams in Regular', () {
      // 4 teams -> (4*3)/2 = 6 matches
      final result = usecase.generateRoundRobin(tTeams, 21);
      expect(result.length, 6);
      
      // Check all matches are unique pairings (simple check)
      final pairings = result.map((m) => {m.teamA.id, m.teamB.id}).toList();
      final uniquePairings = pairings.toSet();
      expect(uniquePairings.length, pairings.length);
    });

    test('should handle odd number of teams by adding a bye (3 teams -> 3 matches)', () {
      // 3 teams + 1 bye = 4 teams effectively -> 3 rounds, 1 match per round = 3 matches
      final result = usecase.generateRoundRobin(tTeams.sublist(0, 3), 21);
      expect(result.length, 3);
    });
  });

  group('generateKnockoutPhase', () {
    test('should return empty list when less than 4 teams are provided', () {
      final result = usecase.generateKnockoutPhase(tTeams.sublist(0, 3), 21);
      expect(result, []);
    });

    test('should return 2 semi-final matches for 4 ranked teams', () {
      final result = usecase.generateKnockoutPhase(tTeams, 21);
      expect(result.length, 2);
      
      // Semi 1: 1st vs 4th
      expect(result[0].teamA.id, '1');
      expect(result[0].teamB.id, '4');
      
      // Semi 2: 2nd vs 3rd
      expect(result[1].teamA.id, '2');
      expect(result[1].teamB.id, '3');
    });
  });
}
