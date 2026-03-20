import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/shuffle_teams.dart';
import 'team_event.dart';
import 'team_state.dart';

class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final ShuffleTeams shuffleTeams;

  TeamBloc({required this.shuffleTeams}) : super(TeamInitial()) {
    on<GenerateTeams>(_onGenerateTeams);
  }

  Future<void> _onGenerateTeams(
    GenerateTeams event,
    Emitter<TeamState> emit,
  ) async {
    emit(TeamLoading());
    final result = await shuffleTeams(event.players);
    result.fold(
      (failure) => emit(const TeamError('Failed to generate teams')),
      (teams) => emit(TeamGenerated(teams, event.players)),
    );
  }
}
