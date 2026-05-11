// lib/screens/vocabulary/vocabulary_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:language_learning_app/app_colors.dart';
import 'package:language_learning_app/models.dart';
import 'package:language_learning_app/app_provider.dart';
import 'package:language_learning_app/common_widgets.dart';
import 'package:language_learning_app/word_detail_screen.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final categories = ['All', ...?provider.selectedLanguage?.categories];
    final words = provider.filteredWords
        .where((w) =>
    _searchQuery.isEmpty ||
        w.word.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        w.translation.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        w.transliteration.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${provider.selectedLanguage?.name ?? ''} Vocabulary'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_rounded, color: AppColors.accent),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search words...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(Icons.close_rounded, color: AppColors.grey),
                )
                    : null,
              ),
            ),
          ),

          // Category chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) => CategoryChip(
                label: categories[i],
                isSelected: provider.selectedCategory == categories[i],
                onTap: () => provider.setCategory(categories[i]),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Word count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${words.length} words',
                  style: const TextStyle(fontSize: 13, color: AppColors.grey),
                ),
              ],
            ),
          ),

          // Word list
          Expanded(
            child: words.isEmpty
                ? const EmptyState(
              emoji: '🔍',
              title: 'No words found',
              subtitle: 'Try a different search term or category',
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: words.length,
              itemBuilder: (ctx, i) => FadeInLeft(
                delay: Duration(milliseconds: i * 40),
                child: _WordCard(word: words[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final WordModel word;
  const _WordCard({required this.word});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WordDetailScreen(word: word)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: word.isLearned ? AppColors.success : AppColors.greyLight,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.word,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.dark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    word.transliteration,
                    style: const TextStyle(fontSize: 13, color: AppColors.primary, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    word.translation,
                    style: const TextStyle(fontSize: 13, color: AppColors.grey),
                  ),
                ],
              ),
            ),

            // Difficulty badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _diffColor(word.difficulty).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _diffLabel(word.difficulty),
                style: TextStyle(fontSize: 10, color: _diffColor(word.difficulty), fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),

            // Favorite
            GestureDetector(
              onTap: () => provider.toggleFavorite(word),
              child: Icon(
                word.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: word.isFavorite ? AppColors.accent : AppColors.grey,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _diffColor(int d) {
    if (d == 1) return AppColors.success;
    if (d == 2) return AppColors.warning;
    return AppColors.error;
  }

  String _diffLabel(int d) {
    if (d == 1) return 'Easy';
    if (d == 2) return 'Medium';
    return 'Hard';
  }
}