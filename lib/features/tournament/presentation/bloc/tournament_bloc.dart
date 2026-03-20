import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shuttle_shuffle/features/team/domain/entities/team.dart';
import 'package:shuttle_shuffle/features/tournament/domain/entities/tournament.dart';
import 'package:uuid/uuid.dart';
import '../../domain/usecases/generate_fixtures.dart';
import 'tournament_event.dart';
import 'tournament_state.dart';

class TournamentBloc extends Bloc<TournamentEvent, TournamentState> {
  final GenerateFixtures generateFixtures;

  TournamentBloc({required this.generateFixtures})
    : super(TournamentInitial()) {
    on<StartTournament>(_onStartTournament);
    on<UpdateMatchResult>(_onUpdateMatchResult);
    on<GenerateNextRound>(_onGenerateNextRound);
  }

  void _onStartTournament(
    StartTournament event,
    Emitter<TournamentState> emit,
  ) {
    emit(TournamentLoading());
    if (state is TournamentActive || state is TournamentFinished) return;
    
    final matches = generateFixtures.generateRoundRobin(
      event.teams,
      event.maxPoints,
    );
    final tournament = Tournament(
      id: const Uuid().v4(),
      type: event.type,
      teams: event.teams,
      matches: matches,
      maxPoints: event.maxPoints,
    );
    emit(TournamentActive(tournament, _calculateStandings(tournament)));
  }

  void _onUpdateMatchResult(
    UpdateMatchResult event,
    Emitter<TournamentState> emit,
  ) {
    if (state is TournamentActive) {
      final currentState = state as TournamentActive;
      final updatedMatches = currentState.tournament.matches.map((m) {
        return m.id == event.match.id ? event.match : m;
      }).toList();

      final updatedTournament = currentState.tournament.copyWith(
        matches: updatedMatches,
      );

      final standings = _calculateStandings(updatedTournament);

      // Check if all matches finished
      if (updatedTournament.matches.every((m) => m.isFinished)) {
        if (updatedTournament.type == TournamentType.roundRobin) {
          // Find winner
          final ranked = _getRankedTeams(updatedTournament, standings);
          if (ranked.isNotEmpty) {
            emit(TournamentFinished(ranked.first, updatedTournament, standings));
            return; // Exit early as we transitioned state
          }
        }
      }

      emit(TournamentActive(updatedTournament, standings));
    }
  }

  void _onGenerateNextRound(
    GenerateNextRound event,
    Emitter<TournamentState> emit,
  ) {
    if (state is TournamentActive) {
      final currentState = state as TournamentActive;
      if (currentState.tournament.type == TournamentType.knockout) {
        // Logic to transition from Group -> Knockout or Semi -> Final
        // For simplicity, let's assume we are moving from Group to Knockout
        // 1. Rank teams
        final rankedTeams = _getRankedTeams(
          currentState.tournament,
          currentState.standings,
        );

        // 2. Generate Knockout Matches
        final knockoutMatches = generateFixtures.generateKnockoutPhase(
          rankedTeams,
          currentState.tournament.maxPoints,
        );

        if (knockoutMatches.isNotEmpty) {
          final updatedTournament = currentState.tournament.copyWith(
            matches: knockoutMatches,
            // In a real app we might want to preserve history, but for this simple version we replace matches
          );
          emit(TournamentActive(updatedTournament, currentState.standings));
        } else {
          // Assume finished? Or not enough teams
        }
      }
    }
  }

  Map<String, int> _calculateStandings(Tournament tournament) {
    final standings = <String, int>{};
    for (var team in tournament.teams) {
      standings[team.id] = 0;
    }

    for (var match in tournament.matches) {
      if (match.isFinished && match.winner != null) {
        standings[match.winner!.id] = (standings[match.winner!.id] ?? 0) + 1;
      }
    }
    return standings;
  }

  List<Team> _getRankedTeams(
    Tournament tournament,
    Map<String, int> standings,
  ) {
    final teams = List<Team>.from(tournament.teams);
    teams.sort(
      (a, b) => (standings[b.id] ?? 0).compareTo(standings[a.id] ?? 0),
    );
    return teams;
  }
}
