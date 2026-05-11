// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:language_learning_app/app_colors.dart';
import 'package:language_learning_app/app_provider.dart';
import 'package:language_learning_app/auth_service.dart';
import 'package:language_learning_app/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final auth = AuthService();
    final progress = provider.userProgress;
    final lang = provider.selectedLanguage;
    final initials = auth.userDisplayName.isNotEmpty ? auth.userDisplayName[0].toUpperCase() : 'L';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ─── Avatar & Name ────────────────────────────────────
            FadeInDown(
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
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      child: Text(initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(auth.userDisplayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              provider.levelTitle,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (lang != null)
                            Row(
                              children: [
                                Text(lang.flagEmoji, style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text('Learning ${lang.name}', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── Stats Row ────────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Row(
                children: [
                  Expanded(child: _StatTile(value: '${progress?.totalXP ?? 0}', label: 'Total XP', icon: '⚡', color: AppColors.warning)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatTile(value: '${progress?.currentStreak ?? 0}', label: 'Streak', icon: '🔥', color: AppColors.error)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatTile(value: '${provider.learnedWords.length}', label: 'Learned', icon: '✅', color: AppColors.success)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── Progress Card ────────────────────────────────────
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Overall Progress', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.dark)),
                        Text(
                          '${(provider.overallProgress * 100).round()}%',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: provider.overallProgress,
                        backgroundColor: AppColors.greyLight,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${provider.learnedWords.length} of ${provider.words.length} words mastered',
                      style: const TextStyle(fontSize: 13, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── Menu Items ───────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
                ),
                child: Column(
                  children: [
                    _MenuItem(
                      icon: Icons.bar_chart_rounded,
                      color: AppColors.primary,
                      title: 'My Progress',
                      subtitle: 'Detailed stats & charts',
                      onTap: () => Navigator.pushNamed(context, '/progress'),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.emoji_events_rounded,
                      color: AppColors.warning,
                      title: 'Achievements',
                      subtitle: '${provider.achievements.where((a) => a.isUnlocked).length} unlocked',
                      onTap: () => Navigator.pushNamed(context, '/achievements'),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.favorite_rounded,
                      color: AppColors.accent,
                      title: 'Favorite Words',
                      subtitle: '${provider.favoriteWords.length} saved',
                      onTap: () => Navigator.pushNamed(context, '/favorites'),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.language_rounded,
                      color: AppColors.success,
                      title: 'Change Language',
                      subtitle: lang?.name ?? 'Select a language',
                      onTap: () => Navigator.pushNamed(context, '/language-select'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── Sign Out ─────────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 250),
              child: GestureDetector(
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Sign Out?'),
                      content: const Text('Your progress is saved locally and will be here when you come back.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await AuthService().signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error.withOpacity(0.2)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: AppColors.error),
                      SizedBox(width: 10),
                      Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final String icon;
  final Color color;

  const _StatTile({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.dark)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.grey),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.greyLight);
  }
}