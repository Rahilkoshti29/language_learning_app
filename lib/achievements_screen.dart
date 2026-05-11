// lib/screens/profile/achievements_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:language_learning_app/app_colors.dart';
import 'package:language_learning_app/app_provider.dart';
import 'package:language_learning_app/common_widgets.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final achievements = provider.achievements;
    final unlocked = achievements.where((a) => a.isUnlocked).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LexiconAppBar(title: 'Achievements'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.warning, Color(0xFFFF6584)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.warning.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 48)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$unlocked / ${achievements.length}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                        Text('Achievements Unlocked', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text('All Achievements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.dark)),
            const SizedBox(height: 14),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.1,
              ),
              itemCount: achievements.length,
              itemBuilder: (ctx, i) {
                final a = achievements[i];
                return FadeInUp(
                  delay: Duration(milliseconds: i * 60),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: a.isUnlocked ? AppColors.white : AppColors.greyLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: a.isUnlocked ? AppColors.warning.withOpacity(0.4) : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: a.isUnlocked
                          ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)]
                          : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              a.isUnlocked ? a.icon : '🔒',
                              style: TextStyle(fontSize: 32, color: a.isUnlocked ? null : Colors.grey),
                            ),
                            if (a.isUnlocked)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('+${a.xpReward}XP', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warning)),
                              ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          a.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: a.isUnlocked ? AppColors.dark : AppColors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.description,
                          style: const TextStyle(fontSize: 11, color: AppColors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}