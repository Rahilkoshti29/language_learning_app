// lib/screens/language/language_select_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:language_learning_app/app_colors.dart';
import 'package:language_learning_app/sample_data.dart';
import 'package:language_learning_app/models.dart';
import 'package:language_learning_app/app_provider.dart';

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  LanguageModel? _selected;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              FadeInDown(
                child: const Text(
                  'Which language\ndo you want to learn?',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark, height: 1.3),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: const Text(
                  'You can change this anytime later',
                  style: TextStyle(fontSize: 14, color: AppColors.grey),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: SampleData.languages.length,
                  itemBuilder: (ctx, i) {
                    final lang = SampleData.languages[i];
                    final isSelected = _selected?.id == lang.id;
                    final gradColors = AppColors.languageGradients[i % AppColors.languageGradients.length];

                    return FadeInLeft(
                      delay: Duration(milliseconds: i * 80),
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = lang),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isSelected ? null : AppColors.white,
                            gradient: isSelected
                                ? LinearGradient(colors: gradColors, begin: Alignment.topLeft, end: Alignment.bottomRight)
                                : null,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : AppColors.greyLight,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected ? gradColors.first.withOpacity(0.3) : Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(lang.flagEmoji, style: const TextStyle(fontSize: 36)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? Colors.white : AppColors.dark,
                                      ),
                                    ),
                                    Text(
                                      lang.nativeName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isSelected ? Colors.white70 : AppColors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${lang.totalWords}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? Colors.white : AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    'words',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected ? Colors.white70 : AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                child: GestureDetector(
                  onTap: _selected == null || provider.isLoading
                      ? null
                      : () async {
                    await provider.selectLanguage(_selected!);
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: _selected != null
                          ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])
                          : null,
                      color: _selected == null ? AppColors.greyLight : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _selected != null
                          ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 6))]
                          : [],
                    ),
                    child: Center(
                      child: provider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Start Learning ${_selected?.name ?? ''}',
                        style: TextStyle(
                          color: _selected != null ? Colors.white : AppColors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}