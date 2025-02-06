import 'package:aqua_filter/screens/main_scrin.dart';
import 'package:flutter/material.dart';

// Определение класса OnboardingScreen как StatefulWidget
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

// Состояние (State) для OnboardingScreen
class OnboardingScreenState extends State<OnboardingScreen> {
  // Создание PageController для управления PageView
  final PageController _pageController = PageController(initialPage: 0);

  // Текущая страница в PageView
  int _currentPage = 0;

  // Данные для экранов настройки
  List<Map<String, String>> onboardingData = [
    {
      'title': 'Выбирайте фильтры',
      'description': 'Наши фильтры очистят вашу воду!',
      'image': 'assets/images/step1.jpg'
    },
    {
      'title': 'Получайте бонусы',
      'description': 'За каждую покупку вы получаете бонусы!',
      'image': 'assets/images/step2.jpg'
    },
    {
      'title': 'Быстрая доставка',
      'description': 'Мы доставляем товары быстро и качественно!',
      'image': 'assets/images/step3.jpg'
    },
  ];

  void _skipOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const MainScreen()), // ✅ Теперь переходим на MainScreen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40), // Небольшой отступ сверху

          // PageView для отображения слайдов настройки
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    // Изображение для текущего слайда
                    Expanded(
                      child: Image.asset(
                        onboardingData[index]['image']!,
                        fit: BoxFit
                            .scaleDown, // Используем BoxFit.scaleDown для адаптивного отображения
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(
                        height: 20), // Отступ между изображением и текстом
                    // Заголовок для текущего слайда
                    Text(
                      onboardingData[index]['title']!,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    // Описание для текущего слайда
                    Text(
                      onboardingData[index]['description']!,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 80), // Отступ перед индикаторами

          // Индикаторы страниц
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
              (index) => GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 10,
                  width: _currentPage == index ? 20 : 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
              height: 40), // Увеличенный отступ перед кнопкой "Пропустить"

          // Кнопка "Пропустить"
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // 80% ширины экрана
            child: ElevatedButton(
              onPressed: _skipOnboarding,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16), // Высота кнопки
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)), // Закругление
              ),
              child: const Text(
                'Пропустить',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),

          const SizedBox(
              height: 50), // 🔥 Увеличенный отступ перед нижним краем
        ],
      ),
    );
  }
}
