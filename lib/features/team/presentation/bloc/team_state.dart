import 'package:equatable/equatable.dart';
import 'package:shuttle_shuffle/features/player/domain/entities/player.dart';
import '../../domain/entities/team.dart';

abstract class TeamState extends Equatable {
  const TeamState();
  
  @override
  List<Object> get props => [];
}

class TeamInitial extends TeamState {}

class TeamLoading extends TeamState {}

class TeamGenerated extends TeamState {
  final List<Team> teams;
  final List<Player> players;

  const TeamGenerated(this.teams, this.players);

  @override
  List<Object> get props => [teams, players];
}

class TeamError extends TeamState {
  final String message;

  const TeamError(this.message);

  @override
  List<Object> get props => [message];
}
