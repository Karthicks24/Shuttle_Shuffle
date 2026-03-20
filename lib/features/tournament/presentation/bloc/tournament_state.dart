import 'package:equatable/equatable.dart';
import 'package:shuttle_shuffle/features/tournament/domain/entities/tournament.dart';
import 'package:shuttle_shuffle/features/team/domain/entities/team.dart';

abstract class TournamentState extends Equatable {
  const TournamentState();
  
  @override
  List<Object> get props => [];
}

class TournamentInitial extends TournamentState {}

class TournamentLoading extends TournamentState {}

class TournamentActive extends TournamentState {
  final Tournament tournament;
  final Map<String, int> standings; // Team ID -> Points

  const TournamentActive(this.tournament, this.standings);

  @override
  List<Object> get props => [tournament, standings];
}

class TournamentFinished extends TournamentState {
  final Team winner;
  final Tournament tournament;
  final Map<String, int> standings;

  const TournamentFinished(this.winner, this.tournament, this.standings);

  @override
  List<Object> get props => [winner, tournament, standings];
}
