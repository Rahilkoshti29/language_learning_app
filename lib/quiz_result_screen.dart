// lib/screens/quiz/quiz_result_screen.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:animate_do/animate_do.dart';
import 'package:language_learning_app/app_colors.dart';
import 'package:language_learning_app/models.dart';
import 'package:language_learning_app/common_widgets.dart';

class QuizResultScreen extends StatefulWidget {
  final QuizResult result;
  const QuizResultScreen({super.key, required this.result});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    if (widget.result.scorePercent >= 70) {
      _confetti.play();
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final score = result.scorePercent.round();
    final isPerfect = score == 100;
    final isGood = score >= 70;
    final xpEarned = result.correctAnswers * 15;

    final emoji = isPerfect ? '🏆' : isGood ? '🎉' : '💪';
    final title = isPerfect ? 'Perfect Score!' : isGood ? 'Great Job!' : 'Keep Practicing!';
    final subtitle = isPerfect
        ? 'You got everything right! Incredible!'
        : isGood
        ? 'You\'re doing amazing. Keep it up!'
        : 'Every mistake is a step forward. Try again!';

    final Color primaryColor = isPerfect
        ? AppColors.warning
        : isGood
        ? AppColors.success
        : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Confetti
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [AppColors.primary, AppColors.accent, AppColors.success, AppColors.warning],
            numberOfParticles: 30,
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Result Hero
                  FadeInDown(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: Column(
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 72)),
                          const SizedBox(height: 16),
                          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14, height: 1.5)),
                          const SizedBox(height: 24),
                          // Score circle
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('$score%', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
                                  Text('Score', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats grid
                  FadeInUp(
                    delay: const Duration(milliseconds: 150),
                    child: Row(
                      children: [
                        Expanded(child: _StatBox(value: '${result.correctAnswers}', label: 'Correct', color: AppColors.success, icon: Icons.check_circle_rounded)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatBox(value: '${result.totalQuestions - result.correctAnswers}', label: 'Wrong', color: AppColors.error, icon: Icons.cancel_rounded)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatBox(value: '${result.timeTaken.inSeconds}s', label: 'Time', color: AppColors.primary, icon: Icons.timer_rounded)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // XP earned
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Text('⚡', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('XP Earned', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                                Text('+$xpEarned XP', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.dark)),
                              ],
                            ),
                          ),
                          Text(result.category, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.grey)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Buttons
                  FadeInUp(
                    delay: const Duration(milliseconds: 250),
                    child: Column(
                      children: [
                        GradientButton(
                          text: 'Try Again',
                          icon: Icons.replay_rounded,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            // Pop back to quiz home (2 screens)
                            Navigator.popUntil(context, (route) => route.isFirst || route.settings.name == '/home');
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: const BorderSide(color: AppColors.greyLight, width: 1.5),
                          ),
                          child: const Text('Back to Home', style: TextStyle(color: AppColors.grey, fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatBox({required this.value, required this.label, required this.color, required this.icon});

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
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
        ],
      ),
    );
  }
}