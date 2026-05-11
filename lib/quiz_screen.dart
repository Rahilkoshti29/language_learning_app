// lib/screens/quiz/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:language_learning_app/app_colors.dart';
import 'package:language_learning_app/models.dart';
import 'package:language_learning_app/app_provider.dart';
import 'package:language_learning_app/common_widgets.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final String category;

  const QuizScreen({super.key, required this.questions, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _correctCount = 0;
  int? _selectedOption;
  bool _answered = false;
  late DateTime _startTime;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index == widget.questions[_currentIndex].correctIndex) {
        _correctCount++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
        _progressController.reset();
        _progressController.forward();
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    final timeTaken = DateTime.now().difference(_startTime);
    final result = QuizResult(
      languageId: widget.questions.first.languageId,
      category: widget.category,
      totalQuestions: widget.questions.length,
      correctAnswers: _correctCount,
      timeTaken: timeTaken,
      completedAt: DateTime.now(),
    );
    context.read<AppProvider>().saveQuizResult(result);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => QuizResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: LexiconAppBar(title: widget.category),
        body: const EmptyState(emoji: '📭', title: 'No Questions', subtitle: 'No quiz available for this category yet.'),
      );
    }

    final question = widget.questions[_currentIndex];
    final progress = (_currentIndex + 1) / widget.questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LexiconAppBar(
        title: widget.category,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentIndex + 1}/${widget.questions.length}',
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.grey),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress + Score
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_rounded, color: AppColors.success, size: 14),
                      const SizedBox(width: 4),
                      Text('$_correctCount', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Question type badge
            FadeInDown(
              key: ValueKey('badge_$_currentIndex'),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    question.type == QuizType.trueFalse ? 'True or False' : 'Multiple Choice',
                    style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Question card
            FadeInDown(
              key: ValueKey('q_$_currentIndex'),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (ctx, i) {
                  Color bgColor = AppColors.white;
                  Color borderColor = AppColors.greyLight;
                  Color textColor = AppColors.dark;
                  Widget? trailingIcon;

                  if (_answered) {
                    if (i == question.correctIndex) {
                      bgColor = AppColors.successLight;
                      borderColor = AppColors.success;
                      textColor = AppColors.success;
                      trailingIcon = const Icon(Icons.check_circle_rounded, color: AppColors.success);
                    } else if (i == _selectedOption && i != question.correctIndex) {
                      bgColor = AppColors.errorLight;
                      borderColor = AppColors.error;
                      textColor = AppColors.error;
                      trailingIcon = const Icon(Icons.cancel_rounded, color: AppColors.error);
                    }
                  } else if (_selectedOption == i) {
                    bgColor = AppColors.primaryLight;
                    borderColor = AppColors.primary;
                    textColor = AppColors.primary;
                  }

                  return FadeInLeft(
                    delay: Duration(milliseconds: i * 60),
                    key: ValueKey('opt_${_currentIndex}_$i'),
                    child: GestureDetector(
                      onTap: () => _selectOption(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1.5),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: borderColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + i), // A, B, C, D
                                  style: TextStyle(fontWeight: FontWeight.w700, color: borderColor == AppColors.greyLight ? AppColors.grey : borderColor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(question.options[i], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor)),
                            ),
                            if (trailingIcon != null) trailingIcon,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Next button (only shows after answering)
            if (_answered)
              FadeInUp(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: GradientButton(
                    text: _currentIndex < widget.questions.length - 1 ? 'Next Question →' : 'See Results 🎉',
                    onPressed: _nextQuestion,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}