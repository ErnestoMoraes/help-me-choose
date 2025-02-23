import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'ranking_screen.dart';

class VotingScreen extends StatefulWidget {
  final String roomId;

  const VotingScreen({super.key, required this.roomId});

  @override
  VotingScreenState createState() => VotingScreenState();
}

class VotingScreenState extends State<VotingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, int> _votes = {}; // Contagem de votos por item
  final List<String> _userVotes = []; // Itens votados pelo usuário (em ordem)
  int _remainingVotes = 3; // Votos restantes do usuário

  void vote(String place) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (_userVotes.contains(place)) {
      // Se o item já foi votado, remove o voto
      await _firestore
          .collection('rooms')
          .doc(widget.roomId)
          .collection('votes')
          .doc(user.uid)
          .delete();

      setState(() {
        _votes[place] = (_votes[place] ?? 1) - 1;
        _userVotes.remove(place); // Remove o item da lista de votos do usuário
        _remainingVotes++; // Recupera um voto
      });
    } else if (_remainingVotes > 0) {
      // Se o item não foi votado e há votos restantes, adiciona o voto
      await _firestore
          .collection('rooms')
          .doc(widget.roomId)
          .collection('votes')
          .doc(user.uid)
          .set({
        'user': user.email,
        'place': place,
        'weight': _remainingVotes, // Peso do voto (3, 2 ou 1)
      });

      setState(() {
        _votes[place] = (_votes[place] ?? 0) + _remainingVotes;
        _userVotes.add(place); // Adiciona o item à lista de votos do usuário
        _remainingVotes--; // Reduz os votos restantes
      });
    }
  }

  void finishVoting(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Atualiza o estado da sala para "ranking"
    await _firestore.collection('rooms').doc(widget.roomId).update({
      'status': 'ranking',
    });

    // Navega para a tela de ranking
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RankingScreen(roomId: widget.roomId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Votação',
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
            // Exibe os votos restantes
            Text(
              'Votos restantes: $_remainingVotes',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Lista de sugestões
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('rooms')
                    .doc(widget.roomId)
                    .collection('suggestions')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    );
                  }
                  final suggestions = snapshot.data!.docs;
                  return Wrap(
                    spacing: 10, // Espaço horizontal entre os itens
                    runSpacing: 10, // Espaço vertical entre as linhas
                    children: suggestions.map((suggestion) {
                      final place = suggestion['place'];
                      final isVoted = _userVotes.contains(place);
                      final voteIndex = _userVotes.indexOf(place);

                      return NeuContainer(
                        width: MediaQuery.of(context).size.width / 2 - 30,
                        borderColor: isVoted ? Colors.white : Colors.black,
                        shadowColor: Colors.black,
                        color: isVoted ? Colors.black : Colors.white,
                        child: InkWell(
                          onTap: () => vote(place),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isVoted)
                                  Icon(
                                    Icons.emoji_events,
                                    color: voteIndex == 0
                                        ? Colors.amber
                                        : voteIndex == 1
                                            ? Colors.grey
                                            : Colors.brown,
                                    size: 24,
                                  ),
                                const SizedBox(width: 10),
                                Text(
                                  place,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isVoted ? Colors.white : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Botão para finalizar a votação
            NeuTextButton(
              onPressed: () => finishVoting(context),
              text: const Text(
                'Finalizar Votação',
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
          ],
        ),
      ),
    );
  }
}
