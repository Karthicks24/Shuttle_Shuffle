import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shuttle_shuffle/features/match/presentation/pages/scoreboard_page.dart';
import 'package:shuttle_shuffle/features/team/domain/entities/team.dart';
import 'package:shuttle_shuffle/features/tournament/domain/entities/tournament.dart';
import 'package:shuttle_shuffle/features/match/domain/entities/match.dart'
    as match_entity;
import 'package:shuttle_shuffle/features/player/presentation/pages/player_input_page.dart';
import 'package:shuttle_shuffle/features/tournament/presentation/pages/tournament_winner_page.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/tournament_bloc.dart';
import '../bloc/tournament_event.dart';
import '../bloc/tournament_state.dart';

class TournamentPage extends StatelessWidget {
  final List<Team> teams;
  final TournamentType type;
  final int maxPoints;

  const TournamentPage({
    super.key,
    required this.teams,
    required this.type,
    this.maxPoints = 21,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<TournamentBloc>()..add(StartTournament(teams, type, maxPoints)),
      child: TournamentView(),
    );
  }
}

class TournamentView extends StatefulWidget {
  const TournamentView({super.key});

  @override
  State<TournamentView> createState() => _TournamentViewState();
}

class _TournamentViewState extends State<TournamentView> {
  // To expand / collapse
  final ValueNotifier<bool> _isExpanded = ValueNotifier<bool>(false);

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _isExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (diaogContext) => AlertDialog(
            backgroundColor: AppColors.primaryBackground,
            title: const Text(
              'Exit Tournament?',
              style: TextStyle(color: Colors.redAccent),
            ),
            content: const Text(
              'Return to Player Input? All tournament progress will be lost.',
              style: TextStyle(color: AppColors.text),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(diaogContext, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.text),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(diaogContext, true),
                child: const Text(
                  'Exit',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Tournament Standings'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
              tooltip: 'Exit Tournament',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    backgroundColor: AppColors.primaryBackground,
                    title: const Text(
                      'Exit Tournament?',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    content: const Text(
                      'All progress will be lost.',
                      style: TextStyle(color: AppColors.text),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.text),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Exit',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          tooltip: "Go back to top",
          child: const Icon(Icons.keyboard_arrow_up_rounded),
        ),
        body: BlocConsumer<TournamentBloc, TournamentState>(
          listener: (context, state) {
            if (state is TournamentFinished) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TournamentWinnerPage(winner: state.winner),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is TournamentLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TournamentActive || state is TournamentFinished) {
              // Extract data safely using Type casting
              final tournament = (state is TournamentActive)
                  ? state.tournament
                  : (state as TournamentFinished).tournament;

              final standings = (state is TournamentActive)
                  ? state.standings
                  : (state as TournamentFinished).standings;

              // Sorted by high points on top in descending order to show top players first
              final sortedEntries = standings.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              return SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Standings Table
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isExpanded,
                        builder: (context, expanded, _) {
                          final displayEntries = expanded
                              ? sortedEntries
                              : sortedEntries.take(4).toList();
                          return Column(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.leaderboard,
                                    color: AppColors.accent,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Standings',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(3),
                                  1: FlexColumnWidth(1),
                                },
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                    ),
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text(
                                          'Team',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text(
                                          'Pts',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // ...state.standings.entries
                                  ...displayEntries.map((entry) {
                                    final team = tournament.teams.firstWhere(
                                      (t) => t.id == entry.key,
                                    );
                                    final teamName = team.players
                                        .map((p) => p.name)
                                        .join(' & ');

                                    return TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(teamName),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            entry.value.toString(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.accent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                              // 4. The "Show More" Button
                              if (sortedEntries.length > 4)
                                TextButton(
                                  onPressed: () {
                                    // Toggle the local state here
                                    _isExpanded.value = !_isExpanded.value;
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        expanded
                                            ? 'Show Less'
                                            : 'Show All Teams',
                                      ),
                                      Icon(
                                        expanded
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.event_note,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Fixtures (${tournament.matches.where((m) => m.isFinished).length}/${tournament.matches.length})',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Fixture List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: tournament.matches.length,
                      itemBuilder: (context, index) {
                        final match = tournament.matches[index];
                        return Card(
                          color: match.isFinished
                              ? Colors.green.withOpacity(0.08)
                              : Colors.white.withOpacity(0.03),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: match.isFinished
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.white12,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 6,
                              children: [
                                Text(
                                  '${match.teamA.players.map((p) => p.name).join(" & ")} vs ${match.teamB.players.map((p) => p.name).join(" & ")}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: match.isFinished
                                        ? Colors.white70
                                        : Colors.white,
                                  ),
                                ),
                                if (match.winner != null) ...[
                                  Text(
                                    'Winner: ${match.winner!.players.map((p) => p.name).join("/")}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: match.isFinished
                                  ? Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent.withOpacity(
                                              0.25,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: AppColors.accent
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                          child: Text(
                                            'Result: ${match.scoreA} - ${match.scoreB}',
                                            style: const TextStyle(
                                              color: AppColors.accent,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Icons.verified,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'FINISHED',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      'In Queue - Tap to start match',
                                      style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 13,
                                      ),
                                    ),
                            ),
                            trailing: match.isFinished
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 28,
                                  )
                                : const Icon(
                                    Icons.play_circle_fill,
                                    color: AppColors.accent,
                                    size: 28,
                                  ),
                            onTap: () async {
                              if (!match.isFinished) {
                                final updatedMatch = await Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (_) => ScoreboardPage(
                                          teamA: match.teamA,
                                          teamB: match.teamB,
                                          matchId: match.id,
                                          maxPoints: tournament.maxPoints,
                                        ),
                                      ),
                                    );

                                if (updatedMatch != null &&
                                    updatedMatch is match_entity.Match) {
                                  // ignore: use_build_context_synchronously
                                  context.read<TournamentBloc>().add(
                                    UpdateMatchResult(updatedMatch),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                    if (tournament.type == TournamentType.knockout &&
                        tournament.matches.every((m) => m.isFinished))
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<TournamentBloc>().add(
                              GenerateNextRound(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.primaryBackground,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Generate Next Knockout Round',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
