// lib/screens/flashcard/flashcard_swipe_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:language_learning_app/app_colors.dart';
import 'package:language_learning_app/models.dart';
import 'package:language_learning_app/app_provider.dart';
import 'package:language_learning_app/common_widgets.dart';

class FlashcardSwipeScreen extends StatefulWidget {
  final List<WordModel> words;
  final String title;

  const FlashcardSwipeScreen({super.key, required this.words, required this.title});

  @override
  State<FlashcardSwipeScreen> createState() => _FlashcardSwipeScreenState();
}

class _FlashcardSwipeScreenState extends State<FlashcardSwipeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;
  int _currentIndex = 0;
  int _knownCount = 0;
  int _unknownCount = 0;
  late FlutterTts _tts;
  late List<WordModel> _shuffledWords;

  @override
  void initState() {
    super.initState();
    _shuffledWords = List.from(widget.words)..shuffle();
    _tts = FlutterTts();
    _tts.setLanguage('hi-IN');
    _tts.setSpeechRate(0.5);

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _nextCard({required bool known}) {
    if (_currentIndex >= _shuffledWords.length - 1) {
      _showResult();
      return;
    }
    if (known) {
      _knownCount++;
      context.read<AppProvider>().markWordLearned(_shuffledWords[_currentIndex]);
    } else {
      _unknownCount++;
    }
    _flipController.reset();
    setState(() {
      _isFlipped = false;
      _currentIndex++;
    });
  }

  void _showResult() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ResultSheet(
        known: _knownCount,
        unknown: _unknownCount,
        total: _shuffledWords.length,
        onRestart: () {
          Navigator.pop(ctx);
          setState(() {
            _shuffledWords.shuffle();
            _currentIndex = 0;
            _knownCount = 0;
            _unknownCount = 0;
            _isFlipped = false;
            _flipController.reset();
          });
        },
        onExit: () {
          Navigator.pop(ctx);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_shuffledWords.isEmpty) {
      return Scaffold(
        appBar: LexiconAppBar(title: widget.title),
        body: const EmptyState(emoji: '🃏', title: 'No cards', subtitle: 'No words in this category'),
      );
    }

    final word = _shuffledWords[_currentIndex];
    final progress = (_currentIndex + 1) / _shuffledWords.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LexiconAppBar(
        title: widget.title,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentIndex + 1}/${_shuffledWords.length}',
                style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.greyLight,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [const Icon(Icons.check_rounded, color: AppColors.success, size: 14), const SizedBox(width: 4), Text('$_knownCount known', style: const TextStyle(fontSize: 12, color: AppColors.success))]),
                Row(children: [const Icon(Icons.close_rounded, color: AppColors.error, size: 14), const SizedBox(width: 4), Text('$_unknownCount to review', style: const TextStyle(fontSize: 12, color: AppColors.error))]),
              ],
            ),

            const SizedBox(height: 24),

            // Hint
            Text(
              _isFlipped ? 'Tap card to see word' : 'Tap card to reveal translation',
              style: const TextStyle(fontSize: 13, color: AppColors.grey),
            ),
            const SizedBox(height: 16),

            // Flashcard
            Expanded(
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (_, __) {
                    final isBack = _flipAnimation.value > 0.5;
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_flipAnimation.value * 3.14159),
                      alignment: Alignment.center,
                      child: isBack
                          ? Transform(
                        transform: Matrix4.identity()..rotateY(3.14159),
                        alignment: Alignment.center,
                        child: _CardBack(word: word),
                      )
                          : _CardFront(word: word, onSpeak: () => _tts.speak(word.word)),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            if (_isFlipped)
              FadeInUp(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _nextCard(known: false),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.error.withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close_rounded, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Still Learning', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _nextCard(known: true),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.success.withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded, color: AppColors.success),
                              SizedBox(width: 8),
                              Text('I Know It!', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 56),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  final WordModel word;
  final VoidCallback onSpeak;

  const _CardFront({required this.word, required this.onSpeak});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          // Pattern
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(word.category, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ),
                const SizedBox(height: 24),
                Text(
                  word.word,
                  style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  word.transliteration,
                  style: TextStyle(fontSize: 20, color: Colors.white.withOpacity(0.75), fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: onSpeak,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final WordModel word;
  const _CardBack({required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Translation', style: TextStyle(fontSize: 14, color: AppColors.grey)),
          const SizedBox(height: 12),
          Text(
            word.translation,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.dark),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 40, color: AppColors.greyLight),
          const Text('Example', style: TextStyle(fontSize: 12, color: AppColors.grey)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              word.exampleSentence,
              style: const TextStyle(fontSize: 16, color: AppColors.dark, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word.exampleTranslation,
            style: const TextStyle(fontSize: 13, color: AppColors.grey, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ResultSheet extends StatelessWidget {
  final int known;
  final int unknown;
  final int total;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const _ResultSheet({
    required this.known,
    required this.unknown,
    required this.total,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? (known / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(percent >= 70 ? '🎉' : '💪', style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            percent >= 70 ? 'Great Job!' : 'Keep Practicing!',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.dark),
          ),
          const SizedBox(height: 8),
          Text('$percent% correct', style: const TextStyle(fontSize: 16, color: AppColors.grey)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ResultStat(value: '$known', label: 'Known', color: AppColors.success),
              _ResultStat(value: '$unknown', label: 'To Review', color: AppColors.error),
              _ResultStat(value: '$total', label: 'Total', color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 28),
          GradientButton(text: 'Restart', onPressed: onRestart),
          const SizedBox(height: 12),
          TextButton(onPressed: onExit, child: const Text('Back to Flashcards', style: TextStyle(color: AppColors.grey))),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _ResultStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
      ],
    );
  }
}