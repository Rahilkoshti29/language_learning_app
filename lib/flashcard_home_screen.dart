// lib/screens/flashcard/flashcard_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:language_learning_app/app_colors.dart';
import 'package:language_learning_app/app_provider.dart';
import 'package:language_learning_app/common_widgets.dart';
import 'package:language_learning_app/flashcard_swipe_screen.dart';

class FlashcardHomeScreen extends StatelessWidget {
  const FlashcardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final categories = ['All', ...?provider.selectedLanguage?.categories];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Flashcards'), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Practice with Flashcards', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(
                            '${provider.words.length} cards available',
                            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => FlashcardSwipeScreen(
                                words: provider.words,
                                title: 'All Words',
                              ),
                            )),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Start All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                                  SizedBox(width: 6),
                                  Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text('🃏', style: TextStyle(fontSize: 60)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick sets
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: const SectionHeader(title: 'Practice Sets'),
            ),
            const SizedBox(height: 14),

            // All category sets
            ...categories.skip(1).toList().asMap().entries.map((entry) {
              final i = entry.key;
              final cat = entry.value;
              final words = provider.words.where((w) => w.category == cat).toList();
              final learned = words.where((w) => w.isLearned).length;
              final colors = AppColors.languageGradients[i % AppColors.languageGradients.length];

              return FadeInLeft(
                delay: Duration(milliseconds: i * 60),
                child: GestureDetector(
                  onTap: words.isEmpty ? null : () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FlashcardSwipeScreen(words: words, title: cat)),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
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
                          child: Center(
                            child: Text(_catEmoji(cat), style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cat, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: words.isEmpty ? 0 : learned / words.length,
                                backgroundColor: AppColors.greyLight,
                                valueColor: AlwaysStoppedAnimation(colors.first),
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 4),
                              Text('$learned/${words.length} learned', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text('${words.length}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13)),
                              const Text(' cards', style: TextStyle(color: AppColors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
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
      'Vocabulary': '📖',
      'Grammar': '✏️',
      'Phrases': '💬',
      'Numbers': '🔢',
      'Colors': '🎨',
      'Food': '🍛',
      'Travel': '✈️',
      'Family': '👨‍👩‍👧',
    };
    return map[cat] ?? '📚';
  }
}