import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../team/domain/entities/team.dart';
import '../bloc/match_bloc.dart';
import '../bloc/match_event.dart';
import '../bloc/match_state.dart';
import '../../domain/entities/match.dart';

class ScoreboardPage extends StatelessWidget {
  final Team teamA;
  final Team teamB;
  final String? matchId;
  final int maxPoints;

  const ScoreboardPage({
    super.key,
    required this.teamA,
    required this.teamB,
    this.matchId,
    this.maxPoints = 21,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MatchBloc>()
        ..add(StartMatch(teamA, teamB, matchId: matchId, maxPoints: maxPoints)),
      child: const ScoreboardView(),
    );
  }
}

class ScoreboardView extends StatelessWidget {
  const ScoreboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Scoreboard'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // final state = context.read<MatchBloc>().state;
            // if (state is MatchInProgress) {
            //   Navigator.of(context).pop(state.match);
            // } else if (state is MatchFinished) {
            //   Navigator.of(context).pop(state.match);
            // } else {
            //   Navigator.of(context).pop();
            // }
            Navigator.of(context).pop(null);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino_outlined, color: AppColors.accent),
            tooltip: 'Toss',
            onPressed: () => _showTossDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MatchBloc>().add(ResetMatch());
            },
          ),
        ],
      ),
      body: BlocConsumer<MatchBloc, MatchState>(
        listener: (context, state) {
          if (state is MatchFinished) {
            final winner = state.match.winner;
            final message = winner != null
                ? 'Team Matches Finished! Winner: Team ${winner.players.map((e) => e.name).join(' & ')}'
                : 'Match Finished!';

            // Fluttertoast.showToast(
            //   msg: message,
            //   toastLength: Toast.LENGTH_LONG,
            //   gravity: ToastGravity.CENTER,
            //   backgroundColor: AppColors.accent,
            //   textColor: AppColors.primaryBackground,
            //   fontSize: 18.0,
            // );
          }
        },
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) {
                return;
              }

              if (context.mounted) {
                Navigator.of(context).pop(null);
              }
            },
            child: _buildBody(context, state),
          );
        },
      ),
    );
  }

  void _showSkipDialog(BuildContext context) {
    final state = context.read<MatchBloc>().state;
    Match? match;
    if (state is MatchInProgress) {
      match = state.match;
    } else if (state is MatchFinished) {
      match = state.match;
    }

    if (match != null) {
      final currentMatch = match; // Fixed for closure promotion
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.primaryBackground,
          title: const Text(
            'Skip Match',
            style: TextStyle(color: AppColors.accent),
          ),
          content: const Text(
            'Who won the match?',
            style: TextStyle(color: AppColors.text),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<MatchBloc>().add(SkipMatch(currentMatch.teamA));
                Navigator.pop(context);
              },
              child: Text(
                'Team A: ${currentMatch.teamA.players.map((p) => p.name).join("/")}',
                style: const TextStyle(color: AppColors.accent),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<MatchBloc>().add(SkipMatch(currentMatch.teamB));
                Navigator.pop(context);
              },
              child: Text(
                'Team B: ${currentMatch.teamB.players.map((p) => p.name).join("/")}',
                style: const TextStyle(color: AppColors.accent),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showTossDialog(BuildContext context) {
    final state = context.read<MatchBloc>().state;
    Team? teamA;
    Team? teamB;

    if (state is MatchInProgress) {
      teamA = state.match.teamA;
      teamB = state.match.teamB;
    } else if (state is MatchFinished) {
      teamA = state.match.teamA;
      teamB = state.match.teamB;
    }

    if (teamA == null || teamB == null) return;

    final winner = Random().nextBool() ? teamA : teamB;
    final winnerName = winner.players.map((p) => p.name).join(" & ");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primaryBackground,
        title: const Row(
          children: [
            Icon(Icons.casino, color: AppColors.accent),
            SizedBox(width: 12),
            Text('Toss Result', style: TextStyle(color: AppColors.accent)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'The coin has landed!',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Text(
              winnerName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'WON THE TOSS!',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Choose your Side or Serve.',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, MatchState state) {
    if (state is MatchInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is MatchInProgress || state is MatchFinished) {
      final match = (state is MatchInProgress)
          ? state.match
          : (state as MatchFinished).match;

      return Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                _buildTeamScoreSection(
                  context,
                  'Team A',
                  match.teamA,
                  match.scoreA,
                  Colors.blueAccent,
                  () => context.read<MatchBloc>().add(ScoreTeamA()),
                  state is MatchFinished,
                ),
                const VerticalDivider(width: 1, color: Colors.white24),
                _buildTeamScoreSection(
                  context,
                  'Team B',
                  match.teamB,
                  match.scoreB,
                  Colors.redAccent,
                  () => context.read<MatchBloc>().add(ScoreTeamB()),
                  state is MatchFinished,
                ),
              ],
            ),
          ),
          if (state is MatchInProgress)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: OutlinedButton.icon(
                onPressed: () => _showSkipDialog(context),
                icon: const Icon(Icons.skip_next),
                label: const Text('Skip / Force Finish'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.accent, width: 1.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (state is MatchFinished && match.winner != null)
            Container(
              padding: const EdgeInsets.all(24.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: const Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Column(
                children: [
                  Text(
                    'Winner: ${match.winner!.players.map((p) => p.name).join(" & ")}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(match);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primaryBackground,
                      elevation: 8,
                      shadowColor: AppColors.accent.withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 64,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Save & Continue',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

Widget _buildTeamScoreSection(
  BuildContext context,
  String label,
  Team team,
  int score,
  Color color,
  VoidCallback onScore,
  bool isFinished,
) {
  return Expanded(
    child: InkWell(
      onTap: isFinished ? null : onScore,
      child: Container(
        width: double.infinity,
        color: color.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              team.players.map((p) => p.name).join('\n'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (!isFinished)
              const Text(
                'Tap to Score',
                style: TextStyle(color: Colors.white38),
              ),
          ],
        ),
      ),
    ),
  );
}
