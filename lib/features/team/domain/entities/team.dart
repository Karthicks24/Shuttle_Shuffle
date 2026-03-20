import 'package:equatable/equatable.dart';
import 'package:shuttle_shuffle/features/player/domain/entities/player.dart';

class Team extends Equatable {
  final String id;
  final List<Player> players;

  const Team({
    required this.id,
    required this.players,
  });

  @override
  List<Object> get props => [id, players];
}

