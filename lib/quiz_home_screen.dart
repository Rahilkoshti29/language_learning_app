// lib/screens/quiz/quiz_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:language_learning_app/app_colors.dart';
import 'package:language_learning_app/app_provider.dart';
import 'package:language_learning_app/common_widgets.dart';
import 'package:language_learning_app/quiz_screen.dart';

class QuizHomeScreen extends StatelessWidget {
  const QuizHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final categories = [...?provider.selectedLanguage?.categories];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Quiz'), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6584), Color(0xFFFF8E53)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Test Your Knowledge', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(
                            'Quizzes taken: ${provider.userProgress?.quizzesTaken ?? 0}',
                            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                questions: provider.getQuizQuestions('All'),
                                category: 'All Words',
                              ),
                            )),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Quick Quiz', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
                                  SizedBox(width: 6),
                                  Icon(Icons.play_arrow_rounded, color: AppColors.accent, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text('🧠', style: TextStyle(fontSize: 60)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: const SectionHeader(title: 'Quiz by Category'),
            ),
            const SizedBox(height: 14),

            ...categories.asMap().entries.map((entry) {
              final i = entry.key;
              final cat = entry.value;
              final colors = AppColors.languageGradients[i % AppColors.languageGradients.length];

              return FadeInLeft(
                delay: Duration(milliseconds: i * 60),
                child: GestureDetector(
                  onTap: () {
                    final questions = provider.getQuizQuestions(cat);
                    if (questions.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No quiz available for this category yet')),
                      );
                      return;
                    }
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => QuizScreen(questions: questions, category: cat),
                    ));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: colors),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(child: Text(_catEmoji(cat), style: const TextStyle(fontSize: 22))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cat, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
                              const Text('Multiple choice & True/False', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.grey),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _catEmoji(String cat) {
    const map = {
      'Vocabulary': '📖', 'Grammar': '✏️', 'Phrases': '💬',
      'Numbers': '🔢', 'Colors': '🎨', 'Food': '🍛', 'Travel': '✈️', 'Family': '👨‍👩‍👧',
    };
    return map[cat] ?? '📚';
  }
}