import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:help_me_choose/screens/home_screen.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

void showNeubrutalismSnackBar(
  BuildContext context,
  String message, {
  Color backgroundColor = Colors.orangeAccent,
  Color textColor = Colors.black,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.white,
      content: NeuSnackBar(
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
      ),
      duration: const Duration(seconds: 4),
    ),
  );
}

class NeuSnackBar extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;

  const NeuSnackBar({
    super.key,
    required this.message,
    this.backgroundColor = Colors.orangeAccent,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showBackToHomeAndDescribeRoom(BuildContext context, String? roomId) {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  showDialog(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: NeuCard(
            cardColor: Colors.white,
            shadowColor: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título
                  const Text(
                    'Sair dessa sala',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mensagem
                  const Text(
                    'Você deseja sair da sala?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Botões
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botão Cancelar
                      NeuTextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        text: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        buttonColor: Colors.white,
                        borderColor: Colors.black,
                        shadowColor: Colors.black,
                        enableAnimation: true,
                        buttonHeight: 40,
                      ),
                      const SizedBox(width: 10),

                      // Botão Sair
                      NeuTextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                          // Exemplo de exclusão do jogador da sala
                          firestore
                              .collection('rooms')
                              .doc(roomId)
                              .collection('players')
                              .doc(auth.currentUser!.uid)
                              .delete();
                        },
                        text: const Text(
                          'Sair',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        buttonColor: Colors.redAccent,
                        borderColor: Colors.black,
                        shadowColor: Colors.black,
                        enableAnimation: true,
                        buttonHeight: 40,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

void showBackToHomeAndDeleteSuggestions(BuildContext context, String roomId) {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  showDialog(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: NeuCard(
            cardColor: Colors.white,
            shadowColor: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título
                  const Text(
                    'Sair dessa sala',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mensagem
                  const Text(
                    'Você deseja sair e excluir apenas suas sugestões?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Botões
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botão Cancelar
                      NeuTextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        text: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        buttonColor: Colors.white,
                        borderColor: Colors.black,
                        shadowColor: Colors.black,
                        enableAnimation: true,
                        buttonHeight: 40,
                      ),
                      const SizedBox(width: 10),

                      NeuTextButton(
                        onPressed: () async {
                          // Exemplo de exclusão das sugestões do jogador
                          await firestore
                              .collection('rooms')
                              .doc(roomId)
                              .collection('suggestions')
                              .where(
                                'user',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.email,
                              )
                              .get()
                              .then((snapshot) {
                            for (final doc in snapshot.docs) {
                              doc.reference.delete();
                            }
                          });

                          // Exemplo de exclusão do jogador da sala
                          await firestore
                              .collection('rooms')
                              .doc(roomId)
                              .collection('players')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .delete();

                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        text: const Text(
                          'Excluir',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        buttonColor: Colors.redAccent,
                        borderColor: Colors.black,
                        shadowColor: Colors.black,
                        enableAnimation: true,
                        buttonHeight: 40,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
