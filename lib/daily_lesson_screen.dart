// lib/screens/daily_lesson/daily_lesson_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:language_learning_app/app_colors.dart';
import 'package:language_learning_app/models.dart';
import 'package:language_learning_app/app_provider.dart';
import 'package:language_learning_app/common_widgets.dart';

class DailyLessonScreen extends StatefulWidget {
  const DailyLessonScreen({super.key});
  @override
  State<DailyLessonScreen> createState() => _DailyLessonScreenState();
}

class _DailyLessonScreenState extends State<DailyLessonScreen> {
  int _currentIndex = 0;
  bool _revealed = false;
  late FlutterTts _tts;
  late List<WordModel> _words;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _tts.setLanguage('hi-IN');
    _tts.setSpeechRate(0.5);
    final lesson = context.read<AppProvider>().dailyLesson;
    _words = lesson?.words ?? [];
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _reveal() => setState(() => _revealed = true);

  void _next() {
    if (_currentIndex < _words.length - 1) {
      context.read<AppProvider>().markWordLearned(_words[_currentIndex]);
      setState(() {
        _currentIndex++;
        _revealed = false;
      });
    } else {
      context.read<AppProvider>().markWordLearned(_words[_currentIndex]);
      context.read<AppProvider>().completeDailyLesson();
      setState(() => _finished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return Scaffold(
        appBar: const LexiconAppBar(title: 'Daily Lesson'),
        body: const EmptyState(emoji: '📚', title: 'No Lesson Today', subtitle: 'You have learned all words!'),
      );
    }

    if (_finished) return _buildFinished(context);

    final word = _words[_currentIndex];
    final progress = (_currentIndex + 1) / _words.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LexiconAppBar(
        title: 'Daily Lesson',
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: XPBadge(xp: context.watch<AppProvider>().dailyLesson?.xpReward ?? 50),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.greyLight,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${_currentIndex + 1}/${_words.length}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.grey)),
              ],
            ),

            const SizedBox(height: 32),

            // Word card
            Expanded(
              child: FadeInDown(
                key: ValueKey(_currentIndex),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.languageGradients[_currentIndex % AppColors.languageGradients.length],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(
                      color: AppColors.languageGradients[_currentIndex % AppColors.languageGradients.length].first.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    )],
                  ),
                  child: Stack(
                    children: [
                      Positioned(top: -30, right: -30, child: Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
                      Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                              child: Text(word.category, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ),
                            const SizedBox(height: 20),
                            Text(word.word, style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800, color: Colors.white), textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            Text(word.transliteration, style: TextStyle(fontSize: 20, color: Colors.white.withOpacity(0.75), fontStyle: FontStyle.italic)),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () => _tts.speak(word.word),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 28),
                              ),
                            ),
                            if (_revealed) ...[
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                  children: [
                                    Text(word.translation, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                                    const SizedBox(height: 8),
                                    Text(word.exampleSentence, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), height: 1.4), textAlign: TextAlign.center),
                                    Text(word.exampleTranslation, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6), fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            if (!_revealed)
              GradientButton(
                text: 'Show Translation',
                onPressed: _reveal,
              )
            else
              FadeInUp(
                child: GradientButton(
                  text: _currentIndex < _words.length - 1 ? 'Next Word →' : 'Complete Lesson 🎉',
                  onPressed: _next,
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFinished(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeInDown(child: const Text('🌟', textAlign: TextAlign.center, style: TextStyle(fontSize: 80))),
              const SizedBox(height: 24),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: const Text('Lesson Complete!', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark)),
              ),
              const SizedBox(height: 12),
              FadeInDown(
                delay: const Duration(milliseconds: 150),
                child: Text(
                  'You learned ${_words.length} new words today!\nKeep going, you\'re doing great!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: AppColors.grey, height: 1.6),
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: XPBadge(xp: context.watch<AppProvider>().dailyLesson?.xpReward ?? 50),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 250),
                child: GradientButton(
                  text: 'Back to Home',
                  icon: Icons.home_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}