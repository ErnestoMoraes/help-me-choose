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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rooms')
                  .doc(roomId)
                  .collection('votes')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  );
                }
                final votes = snapshot.data!.docs;
                final voteCounts = <String, int>{};

                // Soma os pesos dos votos para cada lugar
                for (final vote in votes) {
                  final place = vote['place'];
                  final weight = vote['weight'] ?? 1;
                  voteCounts[place] =
                      (voteCounts[place] ?? 0) + (weight as int);
                }

                // Ordena os lugares por número de votos
                final sortedPlaces = voteCounts.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: sortedPlaces.length,
                  itemBuilder: (context, index) {
                    final entry = sortedPlaces[index];
                    final place = entry.key;
                    final votes = entry.value;

                    // Ícones para os três primeiros colocados
                    IconData? icon;
                    Color? iconColor;
                    if (index == 0) {
                      icon = Icons.emoji_events; // Medalha de ouro
                      iconColor = Colors.amber;
                    } else if (index == 1) {
                      icon = Icons.emoji_events; // Medalha de prata
                      iconColor = Colors.grey;
                    } else if (index == 2) {
                      icon = Icons.emoji_events; // Medalha de bronze
                      iconColor = Colors.brown;
                    }

                    return NeuContainer(
                      borderColor: Colors.black,
                      shadowColor: Colors.black,
                      color: Colors.white,
                      child: ListTile(
                        leading: icon != null
                            ? Icon(
                                icon,
                                color: iconColor,
                                size: 30,
                              )
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                        title: Text(
                          place,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        trailing: Text(
                          'Pontos: $votes',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Botão para encerrar a sala e voltar para a tela inicial
          Padding(
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
              buttonColor: Colors.white,
              borderColor: Colors.black,
              shadowColor: Colors.black,
              enableAnimation: true,
            ),
          ),
        ],
      ),
    );
  }
}
