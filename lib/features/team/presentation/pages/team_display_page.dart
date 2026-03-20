import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shuttle_shuffle/features/team/domain/entities/team.dart';
import 'package:shuttle_shuffle/features/tournament/domain/entities/tournament.dart';
import 'package:shuttle_shuffle/features/tournament/presentation/pages/tournament_page.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:shuttle_shuffle/features/player/domain/entities/player.dart';
import '../bloc/team_bloc.dart';
import '../bloc/team_event.dart';
import '../bloc/team_state.dart';

class TeamDisplayPage extends StatelessWidget {
  final List<Player> players;

  const TeamDisplayPage({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TeamBloc>()..add(GenerateTeams(players)),
      child: const TeamDisplayView(),
    );
  }
}

class TeamDisplayView extends StatelessWidget {
  const TeamDisplayView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generated Teams'), centerTitle: true),
      body: BlocBuilder<TeamBloc, TeamState>(
        builder: (context, state) {
          if (state is TeamLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TeamGenerated) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.teams.length,
                    itemBuilder: (context, index) {
                      final team = state.teams[index];
                      final isSolo = team.players.length == 1;

                      return Card(
                        color: Colors.white.withOpacity(0.05),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isSolo
                              ? const BorderSide(
                                  color: Colors.orangeAccent,
                                  width: 1,
                                )
                              : BorderSide.none,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Team ${index + 1}',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...team.players.map(
                                (p) => Text(
                                  p.name,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              if (isSolo) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Colors.orangeAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Needs a substitute',
                                      style: TextStyle(
                                        color: Colors.orangeAccent.withOpacity(
                                          0.8,
                                        ),
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<TeamBloc>().add(
                              GenerateTeams(state.players),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.accent),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Reshuffle'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (state.teams.length < 2) {
                              Fluttertoast.showToast(
                                msg: 'Need at least 2 teams!',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: AppColors.accent,
                                textColor: AppColors.primaryBackground,
                                fontSize: 16.0,
                              );
                              return;
                            }

                            _showConfigDialog(context, state.teams);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.primaryBackground,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Start Tournament'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is TeamError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showConfigDialog(BuildContext context, List<Team> teams) {
    int selectedPoints = 15;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.primaryBackground,
            title: const Text(
              'Match Configuration',
              style: TextStyle(color: AppColors.accent),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Target Points:',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [11, 15, 21].map((p) {
                    final isSelected = selectedPoints == p;
                    return ChoiceChip(
                      label: Text(p.toString()),
                      selected: isSelected,
                      selectedColor: AppColors.accent,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primaryBackground
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) {
                        if (val) setDialogState(() => selectedPoints = p);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select Tournament Mode:',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.loop, color: AppColors.accent),
                  title: const Text(
                    'Regular Mode',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Each team plays each other once',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TournamentPage(
                          teams: teams,
                          type: TournamentType.roundRobin,
                          maxPoints: selectedPoints,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  // 1. Desaturate the icon to look "locked"
                  leading: Icon(
                    Icons.account_tree,
                    color: const Color.fromRGBO(0, 191, 255, 0.4),
                  ),
                  // 2. Add a "Coming Soon" badge to the trailing side
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 191, 255, 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color.fromRGBO(0, 191, 255, 0.4),
                      ),
                    ),
                    child: const Text(
                      'SOON',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  subtitle: Text(
                    'Knockout Mode (Locked)',
                    style: TextStyle(
                      color: const Color.fromRGBO(255, 255, 255, 0.3),
                    ),
                  ),
                  title: Text(
                    'Tournament Mode',
                    style: TextStyle(
                      color: const Color.fromRGBO(255, 255, 255, 0.5),
                    ),
                  ),
                  onTap: () {},
                ),

                // ListTile(
                //   contentPadding: EdgeInsets.zero,
                //   leading: const Icon(
                //     Icons.account_tree,
                //     color: AppColors.accent,
                //   ),
                //   subtitle: const Text(
                //     'Knockout',
                //     style: TextStyle(color: Colors.white70),
                //   ),
                //   title: const Text(
                //     'Tournament Mode',
                //     style: TextStyle(color: Colors.white),
                //   ),
                //   onTap: () {
                //     Navigator.pop(dialogContext);
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (_) => TournamentPage(
                //           teams: teams,
                //           type: TournamentType.knockout,
                //           maxPoints: selectedPoints,
                //         ),
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
