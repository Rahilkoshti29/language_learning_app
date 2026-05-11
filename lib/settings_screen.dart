// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:language_learning_app/app_colors.dart';
import 'package:language_learning_app/auth_service.dart';
import 'package:language_learning_app/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  bool _autoPlayPronunciation = false;

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LexiconAppBar(title: 'Settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        auth.userDisplayName.isNotEmpty ? auth.userDisplayName[0].toUpperCase() : 'L',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(auth.userDisplayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.dark)),
                          Text(auth.userEmail.isEmpty ? 'Guest User' : auth.userEmail, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            _SectionTitle(title: 'Learning Preferences'),
            const SizedBox(height: 12),

            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
                ),
                child: Column(
                  children: [
                    _SwitchTile(
                      icon: Icons.volume_up_rounded,
                      color: AppColors.primary,
                      title: 'Sound Effects',
                      subtitle: 'Play sounds on correct/wrong answers',
                      value: _soundEnabled,
                      onChanged: (v) => setState(() => _soundEnabled = v),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.greyLight),
                    _SwitchTile(
                      icon: Icons.play_circle_rounded,
                      color: AppColors.success,
                      title: 'Auto Pronunciation',
                      subtitle: 'Speak word automatically on flashcard',
                      value: _autoPlayPronunciation,
                      onChanged: (v) => setState(() => _autoPlayPronunciation = v),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.greyLight),
                    _SwitchTile(
                      icon: Icons.notifications_rounded,
                      color: AppColors.warning,
                      title: 'Daily Reminders',
                      subtitle: 'Get reminded to practice daily',
                      value: _notificationsEnabled,
                      onChanged: (v) => setState(() => _notificationsEnabled = v),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            _SectionTitle(title: 'App'),
            const SizedBox(height: 12),

            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
                ),
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.language_rounded,
                      color: AppColors.primary,
                      title: 'Change Language',
                      onTap: () => Navigator.pushNamed(context, '/language-select'),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.greyLight),
                    _ActionTile(
                      icon: Icons.info_outline_rounded,
                      color: AppColors.grey,
                      title: 'About Lexicon',
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'Lexicon',
                        applicationVersion: '1.0.0',
                        applicationLegalese: 'Indian Language Learning App\nBuilt with Flutter ❤️',
                      ),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.greyLight),
                    _ActionTile(
                      icon: Icons.delete_outline_rounded,
                      color: AppColors.error,
                      title: 'Clear All Progress',
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: const Text('Clear Progress?'),
                            content: const Text('This will delete all your learned words, quiz results, and XP. This cannot be undone.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Clear', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Progress cleared'), backgroundColor: AppColors.error),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Version
            Center(
              child: Text('Lexicon v1.0.0 · Made with ❤️ in Flutter', style: TextStyle(fontSize: 12, color: AppColors.grey.withOpacity(0.6))),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grey, letterSpacing: 0.5));
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({required this.icon, required this.color, required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.dark)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.color, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: color == AppColors.error ? AppColors.error : AppColors.dark)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.grey),
    );
  }
}