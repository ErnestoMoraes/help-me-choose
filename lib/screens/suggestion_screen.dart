import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:help_me_choose/utils/snackbar.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart'; // Certifique-se de adicionar este pacote
import 'package:help_me_choose/screens/votin_screen.dart';

class SuggestionScreen extends StatefulWidget {
  final String roomId;

  const SuggestionScreen({required this.roomId});

  @override
  _SuggestionScreenState createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _controller = TextEditingController();

  void addSuggestion() {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite o nome do restaurante'),
        ),
      );
      return;
    }
    final user = _auth.currentUser;
    if (user != null) {
      _firestore
          .collection('rooms')
          .doc(widget.roomId)
          .collection('suggestions')
          .add({
        'user': user.email,
        'place': _controller.text,
        'votes': 0,
      });
      _controller.clear();
    }
  }

  void startVoting(BuildContext context) async {
    // só vai para a tela de votação se houver pelo menos 3 sugestões
    final suggestionsSnapshot = await _firestore
        .collection('rooms')
        .doc(widget.roomId)
        .collection('suggestions')
        .get();

    if (suggestionsSnapshot.docs.length < 3) {
      showNeubrutalismSnackBar(
        context,
        'Adicione pelo menos 3 sugestões',
      );
      return;
    }
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('rooms').doc(widget.roomId).update({
      'status': 'votation',
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VotingScreen(roomId: widget.roomId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          showBackToHomeAndDeleteSuggestions(context, widget.roomId);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Sugestões',
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
              Row(
                children: [
                  Expanded(
                    child: NeuSearchBar(
                      searchController: _controller,
                      hintText: 'Nome do Restaurante',
                      hintStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      borderColor: Colors.black,
                      shadowColor: Colors.black,
                      inputStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      leadingIcon: const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 0,
                      ),
                      searchBarColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  NeuIconButton(
                    buttonWidth: 50,
                    buttonHeight: 50,
                    onPressed: addSuggestion,
                    borderColor: Colors.black,
                    shadowColor: Colors.black,
                    buttonColor: Colors.greenAccent,
                    enableAnimation: true,
                    icon: const Icon(
                      Icons.add,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              //Quantidade de sugestões cadastradas na sala
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('rooms')
                    .doc(widget.roomId)
                    .collection('suggestions')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }

                  final suggestions = snapshot.data!.docs;
                  return suggestions.isNotEmpty
                      ? Text(
                          '${suggestions.length} ${suggestions.length > 1 ? 'sugestões' : 'sugestão'} cadastrada${suggestions.length > 1 ? 's' : ''}',
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        )
                      : const SizedBox();
                },
              ),

              const SizedBox(height: 10),

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
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      );
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhuma sugestão ainda',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }

                    final suggestions = snapshot.data!.docs;

                    suggestions.sort((a, b) {
                      final placeA = a['place'];
                      final placeB = b['place'];
                      return placeA.compareTo(placeB);
                    });

                    return ListView.separated(
                      itemCount: suggestions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final suggestion = suggestions[index];
                        return NeuContainer(
                          borderColor: Colors.black,
                          shadowColor: Colors.black,
                          color: Colors.white,
                          child: ListTile(
                            title: Text(
                              suggestion['place'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // se o teclado estiver aberto, o botão não será exibido e tiver pelo menos 3 sugestões
              if (MediaQuery.of(context).viewInsets.bottom == 0)
                NeuTextButton(
                  onPressed: () => startVoting(context),
                  text: const Text(
                    'Iniciar Votação',
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
      ),
    );
  }
}
