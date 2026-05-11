// lib/screens/profile/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:language_learning_app/app_colors.dart';
import 'package:language_learning_app/app_provider.dart';
import 'package:language_learning_app/common_widgets.dart';
import 'package:language_learning_app/word_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final favorites = provider.favoriteWords;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LexiconAppBar(
        title: 'Favorite Words',
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('${favorites.length} saved', style: const TextStyle(color: AppColors.grey, fontSize: 13)),
            ),
          ),
        ],
      ),
      body: favorites.isEmpty
          ? const EmptyState(
        emoji: '❤️',
        title: 'No Favorites Yet',
        subtitle: 'Tap the heart icon on any word\nto save it here.',
      )
          : ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: favorites.length,
        itemBuilder: (ctx, i) {
          final word = favorites[i];
          return FadeInLeft(
            delay: Duration(milliseconds: i * 50),
            child: Dismissible(
              key: Key(word.id),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.favorite_border_rounded, color: AppColors.error),
              ),
              onDismissed: (_) => provider.toggleFavorite(word),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WordDetailScreen(word: word)),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(child: Icon(Icons.favorite_rounded, color: AppColors.accent, size: 22)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(word.word, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.dark)),
                            Text(word.transliteration, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontStyle: FontStyle.italic)),
                            Text(word.translation, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
                          ],
                        ),
                      ),
                      if (word.isLearned)
                        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.grey),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}