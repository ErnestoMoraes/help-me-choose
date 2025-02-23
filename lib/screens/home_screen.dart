import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart'; // Certifique-se de adicionar este pacote
import 'wait_room_screen.dart'; // Importe a tela de espera

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            const Text(
              'Bem-vindo ao Help Me Choose!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Escolha uma opção para começar:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Botão "Criar Sala"
            NeuTextButton(
              onPressed: () {
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
              onPressed: () {
                _showJoinRoomDialog(
                    context); // Exibe um diálogo para entrar em uma sala
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
