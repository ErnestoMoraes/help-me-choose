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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      body: Column(
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

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: NeuContainer(
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
                ),
              );
            },
          ),
          // Lista horizontal de usuários aguardando
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('rooms')
                .doc(roomId)
                .collection('players')
                .where('status', isEqualTo: 'waiting ranking')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final players = snapshot.data!.docs;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: 100,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final photoUrl = player['photoUrl'] ?? '';

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : const AssetImage('assets/default_avatar.png')
                                as ImageProvider,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Pódio (1º, 2º e 3º lugares)
                    const Text(
                      'Pódio',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // 1º lugar
                    if (suggestions.isNotEmpty)
                      _buildPodiumItem(
                        context,
                        suggestions[0],
                        position: 1,
                        color: Colors.amber,
                      ),
                    // 2º lugar
                    if (suggestions.length > 1)
                      _buildPodiumItem(
                        context,
                        suggestions[1],
                        position: 2,
                        color: Colors.grey,
                      ),
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
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: NeuTextButton(
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
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
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
