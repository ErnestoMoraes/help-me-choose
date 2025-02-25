import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'home_screen.dart'; // Importe a tela inicial

class RankingScreen extends StatelessWidget {
  final String roomId;

  const RankingScreen({super.key, required this.roomId});

  void _endRoomAndNavigateHome(BuildContext context) async {
    // Atualiza o status da sala para "encerrada"
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .update({'status': 'encerrada'});

    // Navega para a tela inicial
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          _endRoomAndNavigateHome(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 10,
              bottom: 10,
            ),
            child: NeuIconButton(
              onPressed: () => _endRoomAndNavigateHome(context),
              borderColor: Colors.black,
              shadowColor: Colors.black,
              buttonColor: Colors.white,
              icon: const Icon(
                Icons.home,
                color: Colors.black,
                fill: 1,
                weight: 800,
              ),
              enableAnimation: true,
            ),
          ),
          title: const Text(
            'Ranking',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Contagem de usuários que faltam finalizar a votação
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(roomId)
                    .collection('players')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final players = snapshot.data!.docs;
                  final totalPlayers = players.length;
                  final waitingPlayers = players
                      .where((player) => player['status'] == 'waiting ranking')
                      .length;
                  final remainingPlayers = totalPlayers - waitingPlayers;

                  return NeuContainer(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        remainingPlayers == 0
                            ? 'Todos os jogadores votaram!'
                            : 'Faltam $remainingPlayers jogadores!',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Lista horizontal de usuários aguardando
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(roomId)
                    .collection('players')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final players = snapshot.data!.docs;

                  players.sort((a, b) {
                    final statusA = a['status'];
                    final statusB = b['status'];

                    if (statusA == 'waiting ranking') {
                      return -1;
                    }

                    if (statusB == 'waiting ranking') {
                      return 1;
                    }

                    return 0;
                  });

                  return SizedBox(
                    height: 70,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final player = players[index];
                        final photoUrl = player['photoUrl'] ?? '';
                        final status = player['status'];

                        return Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: NeuContainer(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(70),
                            shadowColor: Colors.transparent,
                            borderWidth: 3,
                            width: 70,
                            child: Stack(
                              children: [
                                if (photoUrl.isEmpty)
                                  Center(
                                    child: Text(
                                      player['name'][0],
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                else
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(70),
                                    child: Image.network(
                                      photoUrl,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                if (status != 'waiting ranking')
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(70),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.access_time,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('rooms')
                      .doc(roomId)
                      .collection('suggestions')
                      .orderBy('votes', descending: true) // Ordena por votos
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      );
                    }

                    final suggestions = snapshot.data!.docs;

                    if (suggestions.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhuma sugestão encontrada.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }

                    return ListView(
                      children: [
                        const SizedBox(height: 20),
                        // 1º lugar
                        if (suggestions.isNotEmpty)
                          _buildPodiumItem(
                            context,
                            suggestions[0],
                            position: 1,
                            color: Colors.amber,
                          ),
                        const SizedBox(height: 10),
                        // 2º lugar
                        if (suggestions.length > 1)
                          _buildPodiumItem(
                            context,
                            suggestions[1],
                            position: 2,
                            color: Colors.grey,
                          ),
                        const SizedBox(height: 10),
                        // 3º lugar
                        if (suggestions.length > 2)
                          _buildPodiumItem(
                            context,
                            suggestions[2],
                            position: 3,
                            color: Colors.brown,
                          ),
                        const SizedBox(height: 20),
                        // Restante das sugestões
                        const Text(
                          'Outras Sugestões',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ...suggestions.sublist(3).map((suggestion) {
                          return _buildSuggestionItem(suggestion, suggestions);
                        }).toList(),
                      ],
                    );
                  },
                ),
              ),
              // Botão para encerrar a sala (só aparece quando todos estão aguardando)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(roomId)
                    .collection('players')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final players = snapshot.data!.docs;
                  final allWaiting = players
                      .every((player) => player['status'] == 'waiting ranking');

                  return allWaiting
                      ? NeuTextButton(
                          onPressed: () => _endRoomAndNavigateHome(context),
                          text: const Text(
                            'Encerrar Sala',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          buttonColor: Colors.greenAccent,
                          borderColor: Colors.black,
                          shadowColor: Colors.black,
                          enableAnimation: true,
                        )
                      : const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para exibir um item do pódio
  Widget _buildPodiumItem(
    BuildContext context,
    QueryDocumentSnapshot suggestion, {
    required int position,
    required Color color,
  }) {
    return NeuContainer(
      borderColor: Colors.black,
      shadowColor: Colors.black,
      color: Colors.white,
      child: ListTile(
        leading: Icon(
          Icons.emoji_events,
          color: color,
          size: 30,
        ),
        title: Text(
          suggestion['place'],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        trailing: Text(
          'Pontos: ${suggestion['votes']}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  // Widget para exibir uma sugestão comum
  Widget _buildSuggestionItem(
    QueryDocumentSnapshot suggestion,
    List<QueryDocumentSnapshot> suggestions,
  ) {
    return NeuContainer(
      borderColor: Colors.black,
      shadowColor: Colors.black,
      color: Colors.white,
      child: ListTile(
        leading: Text(
          '${suggestions.indexOf(suggestion) + 1}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        title: Text(
          suggestion['place'],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        trailing: Text(
          'Pontos: ${suggestion['votes']}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
