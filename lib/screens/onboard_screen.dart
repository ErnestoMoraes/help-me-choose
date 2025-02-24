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
      title: 'Bem-vindo ao Help Me Choose!',
      description:
          'Decida com seus amigos onde ir ou o que comer de forma fácil e divertida.',
    ),
    OnboardingItem(
      image: 'assets/onboard/onboard2.jpg',
      title: 'Sugira e Vote!',
      description:
          'Adicione suas sugestões e vote na sua favorita de forma anônima.',
    ),
    OnboardingItem(
      image: 'assets/onboard/onboard3.jpg',
      title: 'Descubra o Vencedor!',
      description:
          'Veja em tempo real qual opção foi a mais votada pelo grupo.',
    ),
  ];

  void _nextPage() async {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      await _completeOnboarding();
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

  Future<void> _completeOnboarding() async {
    await OnboardingManager.setOnboardingShown();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Imagem de fundo dentro de um neucontainer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 120),
            child: NeuContainer(
              borderRadius: BorderRadius.zero,
              color: Colors.white,
              borderWidth: 5,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingItems.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final item = _onboardingItems[index];
                  return Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(50),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(item.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          Positioned(
            bottom: 140,
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
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  NeuTextButton(
                    onPressed: _previousPage,
                    text: const Text(
                      'Anterior',
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
                    buttonHeight: 50,
                    buttonWidth: 120,
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
                Row(
                  children: [
                    ...List.generate(
                      _onboardingItems.length,
                      (index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: NeuCard(
                          cardBorderWidth: 2,
                          cardColor: _currentPage == index
                              ? Colors.white
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          cardHeight: 20,
                          cardWidth: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                NeuTextButton(
                  onPressed: _nextPage,
                  text: Text(
                    _currentPage == _onboardingItems.length - 1
                        ? 'Começar'
                        : 'Próximo',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  buttonColor: _currentPage == _onboardingItems.length - 1
                      ? Colors.green
                      : Colors.blue,
                  borderColor: Colors.black,
                  shadowColor: Colors.black,
                  enableAnimation: true,
                  buttonHeight: 50,
                  buttonWidth: 120,
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
