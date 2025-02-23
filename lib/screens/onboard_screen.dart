import 'package:flutter/material.dart';
import 'package:help_me_choose/shared_preference/onboard_sp.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
        image: 'assets/onboard/onboard1.jpg',
        title: 'Bem-vindo ao FoodFight!',
        description:
            'Escolha o melhor lugar para comer com seus amigos e divirta-se!'),
    OnboardingItem(
        image: 'assets/onboard/onboard2.jpg',
        title: 'Sugira e Vote!',
        description:
            'Adicione suas sugestões de restaurantes e vote na sua favorita.'),
    OnboardingItem(
        image: 'assets/onboard/onboard3.jpg',
        title: 'Descubra o Vencedor!',
        description:
            'Veja em tempo real qual restaurante foi o mais votado pelo grupo.'),
  ];

  void _nextPage() async {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      await OnboardingManager.setOnboardingShown();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingItems.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final item = _onboardingItems[index];
              return Image.asset(
                item.image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),

          // Gradiente escuro na parte inferior
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
            ),
          ),

          // Textos
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  _onboardingItems[_currentPage].title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  _onboardingItems[_currentPage].description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Botões de navegação
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  NeuTextButton(
                    onPressed: _previousPage,
                    text: const Text('Anterior'),
                    buttonColor: Colors.white,
                    borderColor: Colors.black,
                    shadowColor: Colors.black,
                    enableAnimation: true,
                  ),
                const Spacer(),
                NeuTextButton(
                  onPressed: _nextPage,
                  text: _currentPage == _onboardingItems.length - 1
                      ? const Text('Começar')
                      : const Text('Próximo'),
                  buttonColor: Colors.white,
                  borderColor: Colors.black,
                  shadowColor: Colors.black,
                  enableAnimation: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String image;
  final String title;
  final String description;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });
}
