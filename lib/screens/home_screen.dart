import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:help_me_choose/screens/login_screen.dart';
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
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: NeuCard(
                      cardColor: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: user?.photoURL != null
                                  ? NetworkImage(user!.photoURL!)
                                  : const AssetImage(
                                          'assets/default_avatar.png')
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  NeuIconButton(
                    onPressed: () async {
                      if (await Vibration.hasVibrator()) {
                        Vibration.vibrate(duration: 100);
                      }
                    },
                    icon: const Icon(Icons.sort_rounded, color: Colors.white),
                    enableAnimation: true,
                    buttonHeight: 40,
                    buttonWidth: 40,
                  ),
                  const SizedBox(width: 10),
                  NeuIconButton(
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
                    icon: const Icon(Icons.logout, color: Colors.white),
                    buttonColor: Colors.redAccent,
                    enableAnimation: true,
                    buttonHeight: 40,
                    buttonWidth: 40,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Botão "Criar Sala"
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
                const SizedBox(height: 20),

                // Botão "Entrar em uma Sala"
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
          ],
        ),
      ),
    );
  }

  // Diálogo para entrar em uma sala
  void _showJoinRoomDialog(BuildContext context) {
    final TextEditingController _roomIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Entrar em uma Sala',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: NeuSearchBar(
            searchController: _roomIdController,
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
              buttonColor: Colors.white,
              borderColor: Colors.black,
              shadowColor: Colors.black,
              enableAnimation: true,
            ),
            NeuTextButton(
              onPressed: () {
                final roomId = _roomIdController.text.trim();
                if (roomId.isNotEmpty) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WaitingRoomScreen(),
                    ),
                  );
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
              buttonColor: Colors.white,
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
