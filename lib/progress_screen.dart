// lib/screens/progress/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:language_learning_app/app_colors.dart';
import 'package:language_learning_app/app_provider.dart';
import 'package:language_learning_app/common_widgets.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final progress = provider.userProgress;
    final lang = provider.selectedLanguage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LexiconAppBar(title: 'My Progress'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level card
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: const Color(0xFF667EEA).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Level', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Text(provider.levelTitle, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          Text('${progress?.totalXP ?? 0} XP earned', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14)),
                        ],
                      ),
                    ),
                    const Text('🎓', style: TextStyle(fontSize: 56)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 4 Stats
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  StatCard(value: '${provider.learnedWords.length}', label: 'Words Learned', icon: Icons.check_circle_rounded, color: AppColors.success),
                  StatCard(value: '${progress?.quizzesTaken ?? 0}', label: 'Quizzes Taken', icon: Icons.quiz_rounded, color: AppColors.primary),
                  StatCard(value: '${progress?.currentStreak ?? 0}🔥', label: 'Day Streak', icon: Icons.local_fire_department_rounded, color: AppColors.warning),
                  StatCard(value: '${progress?.longestStreak ?? 0}', label: 'Best Streak', icon: Icons.star_rounded, color: AppColors.accent),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Category progress
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Progress by Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.dark)),
                    const SizedBox(height: 16),
                    ...?lang?.categories.map((cat) {
                      final catWords = provider.words.where((w) => w.category == cat).toList();
                      final learned = catWords.where((w) => w.isLearned).length;
                      final pct = catWords.isEmpty ? 0.0 : learned / catWords.length;
                      final colors = AppColors.languageGradients[lang.categories.indexOf(cat) % AppColors.languageGradients.length];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(cat, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.dark)),
                                Text('$learned/${catWords.length}', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: AppColors.greyLight,
                                valueColor: AlwaysStoppedAnimation(colors.first),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Words pie chart
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Words Overview', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.dark)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: provider.words.isEmpty
                          ? const Center(child: Text('No data yet', style: TextStyle(color: AppColors.grey)))
                          : PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 50,
                          sections: [
                            PieChartSectionData(
                              value: provider.learnedWords.length.toDouble().clamp(1, double.infinity),
                              color: AppColors.success,
                              title: '${provider.learnedWords.length}\nLearned',
                              radius: 50,
                              titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            PieChartSectionData(
                              value: (provider.words.length - provider.learnedWords.length).toDouble().clamp(1, double.infinity),
                              color: AppColors.greyLight,
                              title: '${provider.words.length - provider.learnedWords.length}\nLeft',
                              radius: 45,
                              titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}