import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart'; // Certifique-se de adicionar este pacote
import 'suggestion_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({super.key});

  @override
  WaitingRoomScreenState createState() => WaitingRoomScreenState();
}

class WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _roomId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _joinOrCreateRoom();
  }

  Future<void> _joinOrCreateRoom() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final roomsSnapshot = await _firestore
        .collection('rooms')
        .where('status', isEqualTo: 'aguardando')
        .limit(1)
        .get();

    if (roomsSnapshot.docs.isNotEmpty) {
      _roomId = roomsSnapshot.docs.first.id;
      await _firestore
          .collection('rooms')
          .doc(_roomId)
          .collection('players')
          .doc(user.uid)
          .set({
        'email': user.email,
        'name': user.displayName,
        'status': 'aguardando',
        'photoUrl': user.photoURL ??
            'https://via.placeholder.com/150', // Foto do usuário
      });
    } else {
      final roomRef = await _firestore.collection('rooms').add({
        'createdAt': DateTime.now(),
        'status': 'aguardando',
      });
      _roomId = roomRef.id;
      await _firestore
          .collection('rooms')
          .doc(_roomId)
          .collection('players')
          .doc(user.uid)
          .set({
        'email': user.email,
        'name': user.displayName,
        'status': 'aguardando',
        'photoUrl': user.photoURL ??
            'https://via.placeholder.com/150', // Foto do usuário
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _startGame(BuildContext context) async {
    if (_roomId == null) return;

    await _firestore.collection('rooms').doc(_roomId).update({
      'status': 'em andamento',
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => SuggestionScreen(roomId: _roomId!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Sala de Espera',
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
        body: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.black,
            size: 80,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Sala de Espera',
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: NeuContainer(
              borderColor: Colors.black,
              shadowColor: Colors.black,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Compartilhe o código da sala',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _roomId!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        NeuIconButton(
                          buttonWidth: 40,
                          buttonHeight: 40,
                          borderRadius: BorderRadius.circular(8),
                          onPressed: () {
                            if (_roomId != null) {
                              Clipboard.setData(ClipboardData(text: _roomId!));
                            }
                          },
                          borderColor: Colors.black,
                          shadowColor: Colors.black,
                          buttonColor: Colors.white,
                          enableAnimation: true,
                          icon: const Icon(Icons.copy, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('rooms')
                  .doc(_roomId)
                  .collection('players')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  );
                }
                final players = snapshot.data!.docs;
                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return NeuContainer(
                      borderColor: Colors.black,
                      shadowColor: Colors.black,
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(player['photoUrl']),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${player['name'].split(' ').first} ${player['name'].split(' ')[1]}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: NeuTextButton(
              onPressed: () => _startGame(context),
              text: const Text(
                'Iniciar Game',
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
