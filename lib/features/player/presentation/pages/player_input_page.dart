import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../team/presentation/pages/team_display_page.dart';
import '../bloc/player_bloc.dart';
import '../bloc/player_event.dart';
import '../bloc/player_state.dart';

class PlayerInputPage extends StatelessWidget {
  const PlayerInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PlayerBloc>()..add(LoadPlayers()),
      child: const PlayerInputView(),
    );
  }
}

class PlayerInputView extends StatefulWidget {
  const PlayerInputView({super.key});

  @override
  State<PlayerInputView> createState() => _PlayerInputViewState();
}

class _PlayerInputViewState extends State<PlayerInputView> {
  final TextEditingController _controller = TextEditingController();

  void _addPlayer() {
    if (_controller.text.trim().isNotEmpty) {
      context.read<PlayerBloc>().add(AddPlayerEvent(_controller.text.trim()));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // FocusScope.of(context).unfocus();
        // This is the "Nuclear Option" — it hits the global focus manager
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: AppBar(title: const Text('Players'), centerTitle: true),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(color: AppColors.text),
                        decoration: InputDecoration(
                          hintText: 'Enter player name',
                          hintStyle: TextStyle(
                            color: AppColors.text.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => _addPlayer(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _addPlayer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primaryBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<PlayerBloc, PlayerState>(
                  builder: (context, state) {
                    if (state is PlayerLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PlayerLoaded) {
                      if (state.players.isEmpty) {
                        return Center(
                          child: Text(
                            'No players added yet.',
                            style: TextStyle(
                              color: AppColors.text.withOpacity(0.5),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.players.length,
                        itemBuilder: (context, index) {
                          final player = state.players[index];
                          return Card(
                            color: Colors.white.withOpacity(0.05),
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Text(
                                "${index + 1}.",
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 15,
                                ),
                              ),
                              title: Text(
                                player.name,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  context.read<PlayerBloc>().add(
                                    RemovePlayerEvent(player.id),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is PlayerError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // This is the "Nuclear Option" — it hits the global focus manager
                      FocusManager.instance.primaryFocus?.unfocus();

                      final state = context.read<PlayerBloc>().state;
                      if (state is PlayerLoaded && state.players.length >= 2) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                TeamDisplayPage(players: state.players),
                          ),
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: 'Add at least 2 players to shuffle!',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.redAccent,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
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
                      'Shuffle Teams',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
