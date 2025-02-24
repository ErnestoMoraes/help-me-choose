import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:help_me_choose/screens/login_screen.dart';
import 'package:help_me_choose/utils/snackbar.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'package:vibration/vibration.dart';
import 'wait_room_screen.dart'; // Importe a tela de espera

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Help Me Choose',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seção do usuário
            NeuCard(
              cardColor: Colors.white,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : const AssetImage('assets/default_avatar.png')
                              as ImageProvider,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${user?.displayName?.split(' ').first} ${user?.displayName?.split(' ').last}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    NeuIconButton(
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Em breve!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.sort_rounded, color: Colors.black),
                      buttonColor: Colors.white,
                      borderColor: Colors.black,
                      shadowColor: Colors.black,
                      enableAnimation: true,
                      buttonHeight: 40,
                      buttonWidth: 40,
                    ),
                    const SizedBox(width: 10),
                    NeuIconButton(
                      onPressed: () async {
                        _showLogoutDialog(context);
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      buttonColor: Colors.redAccent,
                      enableAnimation: true,
                      buttonHeight: 40,
                      buttonWidth: 40,
                    ),
                  ],
                ),
              ),
            ),

            // Botões principais
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NeuTextButton(
                    onPressed: () async {
                      if (await Vibration.hasVibrator()) {
                        Vibration.vibrate(duration: 100);
                      }
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WaitingRoomScreen(),
                        ),
                      );
                    },
                    text: const Text(
                      'Criar Sala',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    buttonColor: Colors.white,
                    borderColor: Colors.black,
                    shadowColor: Colors.black,
                    enableAnimation: true,
                    buttonHeight: 60,
                  ),
                  const SizedBox(height: 20),
                  NeuTextButton(
                    onPressed: () async {
                      if (await Vibration.hasVibrator()) {
                        Vibration.vibrate(duration: 100);
                      }
                      _showJoinRoomDialog(context);
                    },
                    text: const Text(
                      'Entrar em uma Sala',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    buttonColor: Colors.white,
                    borderColor: Colors.black,
                    shadowColor: Colors.black,
                    enableAnimation: true,
                    buttonHeight: 60,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: const BorderSide(
              color: Colors.black,
              width: 4,
            ),
          ),
          title: const Text(
            'Sair da Conta',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: const Text(
            'Tem certeza que deseja sair da sua conta?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          actions: [
            NeuTextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o diálogo
              },
              text: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              buttonColor: Colors.redAccent,
              borderColor: Colors.black,
              shadowColor: Colors.black,
              enableAnimation: true,
            ),
            NeuTextButton(
              onPressed: () async {
                if (await Vibration.hasVibrator()) {
                  Vibration.vibrate(duration: 100);
                }
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              text: const Text(
                'Sair',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              buttonColor: Colors.greenAccent,
              borderColor: Colors.black,
              shadowColor: Colors.black,
              enableAnimation: true,
            ),
          ],
        );
      },
    );
  }

  void _showJoinRoomDialog(BuildContext context) {
    final TextEditingController roomIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: const BorderSide(
              color: Colors.black,
              width: 4,
            ),
          ),
          title: const Text(
            'Entrar em uma Sala',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: NeuSearchBar(
            searchController: roomIdController,
            hintText: 'Digite o código da sala',
            hintStyle: const TextStyle(color: Colors.grey),
            searchBarColor: Colors.white,
            borderColor: Colors.black,
            shadowColor: Colors.black,
            leadingIcon: const Icon(
              Icons.qr_code,
              color: Colors.white,
              size: 0,
            ),
          ),
          actions: [
            NeuTextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o diálogo
              },
              text: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              buttonColor: Colors.redAccent,
              borderColor: Colors.black,
              shadowColor: Colors.black,
              enableAnimation: true,
            ),
            NeuTextButton(
              onPressed: () {
                final roomId = roomIdController.text.trim();
                if (roomId.isNotEmpty) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WaitingRoomScreen(),
                    ),
                  );
                } else {
                  showNeubrutalismSnackBar(
                    context,
                    'Digite o código da sala para entrar.',
                    backgroundColor: Colors.amberAccent,
                  );
                  Navigator.pop(context);
                }
              },
              text: const Text(
                'Entrar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              buttonColor: Colors.greenAccent,
              borderColor: Colors.black,
              shadowColor: Colors.black,
              enableAnimation: true,
            ),
          ],
        );
      },
    );
  }
}
