// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:language_learning_app/app_colors.dart';
import 'package:language_learning_app/app_provider.dart';
import 'package:language_learning_app/auth_service.dart';
import 'package:language_learning_app/common_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final auth = AuthService();
    final lang = provider.selectedLanguage;
    final progress = provider.userProgress;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => provider.selectedLanguage != null
              ? provider.selectLanguage(provider.selectedLanguage!)
              : null,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header
                FadeInDown(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good ${_greeting()},',
                              style: const TextStyle(fontSize: 14, color: AppColors.grey),
                            ),
                            Text(
                              auth.userDisplayName.split(' ').first,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.dark),
                            ),
                          ],
                        ),
                      ),
                      XPBadge(xp: progress?.totalXP ?? 0),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/settings'),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            auth.userDisplayName.isNotEmpty ? auth.userDisplayName[0].toUpperCase() : 'L',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Language banner
                if (lang != null)
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: _LanguageBanner(provider: provider),
                  ),

                const SizedBox(height: 24),

                // Daily Lesson
                FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  child: _DailyLessonCard(provider: provider),
                ),

                const SizedBox(height: 24),

                // Stats Row
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          value: '${provider.learnedWords.length}',
                          label: 'Words Learned',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          value: '${progress?.currentStreak ?? 0}🔥',
                          label: 'Day Streak',
                          icon: Icons.local_fire_department_rounded,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          value: '${progress?.quizzesTaken ?? 0}',
                          label: 'Quizzes Done',
                          icon: Icons.quiz_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Categories
                FadeInUp(
                  delay: const Duration(milliseconds: 250),
                  child: const SectionHeader(title: 'Browse Categories'),
                ),
                const SizedBox(height: 14),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: _CategoryGrid(provider: provider),
                ),

                const SizedBox(height: 24),

                // Recent favorites
                if (provider.favoriteWords.isNotEmpty) ...[
                  FadeInUp(
                    delay: const Duration(milliseconds: 350),
                    child: SectionHeader(
                      title: 'Favorites',
                      actionText: 'See All',
                      onAction: () => Navigator.pushNamed(context, '/favorites'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.favoriteWords.take(5).length,
                      itemBuilder: (ctx, i) {
                        final word = provider.favoriteWords[i];
                        return FadeInRight(
                          delay: Duration(milliseconds: 100 * i),
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primaryLight, width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(word.word, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.dark)),
                                const SizedBox(height: 4),
                                Text(word.translation, style: const TextStyle(fontSize: 12, color: AppColors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _LanguageBanner extends StatelessWidget {
  final AppProvider provider;
  const _LanguageBanner({required this.provider});

  @override
  Widget build(BuildContext context) {
    final lang = provider.selectedLanguage!;
    final progress = provider.overallProgress;
    final index = provider.words.length % 6;
    final colors = AppColors.languageGradients[index];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: colors.first.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Text(lang.flagEmoji, style: const TextStyle(fontSize: 44)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                Text(lang.nativeName, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${provider.learnedWords.length} / ${provider.words.length} words',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/language-select'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Change', style: TextStyle(fontSize: 12, decoration: TextDecoration.underline, decorationColor: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _DailyLessonCard extends StatelessWidget {
  final AppProvider provider;
  const _DailyLessonCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final lesson = provider.dailyLesson;
    if (lesson == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: lesson.isCompleted ? null : () => Navigator.pushNamed(context, '/daily-lesson'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: lesson.isCompleted ? AppColors.successLight : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: lesson.isCompleted ? AppColors.success.withOpacity(0.3) : AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lesson.isCompleted ? AppColors.success : AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                lesson.isCompleted ? Icons.check_rounded : Icons.wb_sunny_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.isCompleted ? 'Daily Lesson Complete!' : 'Daily Lesson',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: lesson.isCompleted ? AppColors.success : AppColors.primary,
                    ),
                  ),
                  Text(
                    lesson.isCompleted ? 'Great job today! Come back tomorrow.' : '${lesson.words.length} words · +${lesson.xpReward} XP',
                    style: const TextStyle(fontSize: 13, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            if (!lesson.isCompleted)
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final AppProvider provider;
  const _CategoryGrid({required this.provider});

  static const _categoryIcons = {
    'Vocabulary': ('📖', AppColors.primary),
    'Grammar': ('✏️', Color(0xFFFF6584)),
    'Phrases': ('💬', Color(0xFF43C59E)),
    'Numbers': ('🔢', Color(0xFFFFB347)),
    'Colors': ('🎨', Color(0xFF667EEA)),
    'Food': ('🍛', Color(0xFFFF8E53)),
    'Travel': ('✈️', Color(0xFF11998E)),
    'Family': ('👨‍👩‍👧', Color(0xFFFF6584)),
  };

  @override
  Widget build(BuildContext context) {
    final cats = provider.selectedLanguage?.categories ?? [];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: cats.length,
      itemBuilder: (ctx, i) {
        final cat = cats[i];
        final icon = _categoryIcons[cat] ?? ('📚', AppColors.primary);
        return GestureDetector(
          onTap: () {
            provider.setCategory(cat);
            Navigator.pushNamed(context, '/vocabulary');
          },
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: icon.$2.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text(icon.$1, style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(height: 6),
              Text(
                cat,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppColors.dark, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}