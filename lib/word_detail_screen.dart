// lib/screens/vocabulary/word_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:language_learning_app/app_colors.dart';
import 'package:language_learning_app/models.dart';
import 'package:language_learning_app/app_provider.dart';
import 'package:language_learning_app/common_widgets.dart';

class WordDetailScreen extends StatefulWidget {
  final WordModel word;
  const WordDetailScreen({super.key, required this.word});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  late FlutterTts _tts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _tts.setLanguage('hi-IN');
    _tts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    setState(() => _isSpeaking = true);
    await _tts.speak(text);
    setState(() => _isSpeaking = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final word = widget.word;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LexiconAppBar(
        title: 'Word Detail',
        actions: [
          IconButton(
            icon: Icon(
              word.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: word.isFavorite ? AppColors.accent : AppColors.grey,
            ),
            onPressed: () => provider.toggleFavorite(word),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main word card
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(
                  children: [
                    Text(
                      word.word,
                      style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      word.transliteration,
                      style: TextStyle(fontSize: 20, color: Colors.white.withOpacity(0.8), fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '/${word.pronunciation}/',
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _speak(word.word),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(_isSpeaking ? 'Playing...' : 'Listen', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Translation
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: _InfoCard(
                title: 'Translation',
                content: word.translation,
                icon: Icons.translate_rounded,
                color: AppColors.success,
              ),
            ),

            const SizedBox(height: 12),

            // Category & Difficulty
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      title: 'Category',
                      content: word.category,
                      icon: Icons.category_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      title: 'Difficulty',
                      content: _diffLabel(word.difficulty),
                      icon: Icons.bar_chart_rounded,
                      color: _diffColor(word.difficulty),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Example sentence
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        const Text('Example Sentence', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.dark)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _speak(word.exampleSentence),
                          child: const Icon(Icons.volume_up_rounded, color: AppColors.grey, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        word.exampleSentence,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.dark, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      word.exampleTranslation,
                      style: const TextStyle(fontSize: 14, color: AppColors.grey, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Mark as Learned
            FadeInUp(
              delay: const Duration(milliseconds: 250),
              child: word.isLearned
                  ? Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.success),
                    SizedBox(width: 8),
                    Text('Already Learned!', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                  ],
                ),
              )
                  : GradientButton(
                text: 'Mark as Learned  +10 XP',
                icon: Icons.check_rounded,
                onPressed: () async {
                  await provider.markWordLearned(word);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Word marked as learned! +10 XP 🎉'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Color _diffColor(int d) {
    if (d == 1) return AppColors.success;
    if (d == 2) return AppColors.warning;
    return AppColors.error;
  }

  String _diffLabel(int d) {
    if (d == 1) return 'Easy';
    if (d == 2) return 'Medium';
    return 'Hard';
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _InfoCard({required this.title, required this.content, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
        ],
      ),
    );
  }
}