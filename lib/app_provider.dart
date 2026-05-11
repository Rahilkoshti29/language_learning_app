// lib/core/providers/app_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:language_learning_app/models.dart';
import 'package:language_learning_app/sample_data.dart';
import 'package:language_learning_app/database_service.dart';
import 'package:language_learning_app/auth_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();

  // Selected language
  LanguageModel? _selectedLanguage;
  LanguageModel? get selectedLanguage => _selectedLanguage;

  // Words state
  List<WordModel> _words = [];
  List<WordModel> get words => _words;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  List<WordModel> get filteredWords {
    if (_selectedCategory == 'All') return _words;
    return _words.where((w) => w.category == _selectedCategory).toList();
  }

  List<WordModel> get favoriteWords =>
      _words.where((w) => w.isFavorite).toList();

  List<WordModel> get learnedWords =>
      _words.where((w) => w.isLearned).toList();

  // Progress
  UserProgress? _userProgress;
  UserProgress? get userProgress => _userProgress;

  // Quiz results
  List<QuizResult> _quizHistory = [];
  List<QuizResult> get quizHistory => _quizHistory;

  // Achievements
  Set<String> _unlockedAchievements = {};
  List<Achievement> get achievements => SampleData.achievements
      .map((a) => Achievement(
    id: a.id,
    title: a.title,
    description: a.description,
    icon: a.icon,
    xpReward: a.xpReward,
    isUnlocked: _unlockedAchievements.contains(a.id),
  ))
      .toList();

  // Daily lesson
  DailyLesson? _dailyLesson;
  DailyLesson? get dailyLesson => _dailyLesson;
  bool get isDailyLessonCompleted => _dailyLesson?.isCompleted ?? false;

  // Loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // onboarding
  bool _hasCompletedOnboarding = false;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding = prefs.getBool('onboarding_done') ?? false;
    _unlockedAchievements = await _db.getUnlockedAchievements();
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  Future<void> selectLanguage(LanguageModel language) async {
    _isLoading = true;
    notifyListeners();

    _selectedLanguage = language;
    await _loadWords(language.id);
    await _loadProgress(language.id);
    _generateDailyLesson();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadWords(String languageId) async {
    List<WordModel> raw = [];
    if (languageId == 'hindi') raw = SampleData.getHindiWords();
    else if (languageId == 'gujarati') raw = SampleData.getGujaratiWords();
    else raw = SampleData.getHindiWords(); // fallback

    // Merge with local progress
    final progress = await _db.getWordProgressForLanguage(languageId);
    _words = raw.map((w) {
      final p = progress[w.id];
      if (p != null) {
        return w.copyWith(
          isFavorite: p['isFavorite'] == 1,
          isLearned: p['isLearned'] == 1,
          reviewCount: p['reviewCount'] as int,
        );
      }
      return w;
    }).toList();
  }

  Future<void> _loadProgress(String languageId) async {
    _userProgress = await _db.getUserProgress(languageId);
    _userProgress ??= UserProgress(languageId: languageId);
    _updateStreak();
  }

  void _updateStreak() {
    if (_userProgress == null) return;
    final today = DateTime.now();
    final last = _userProgress!.lastActiveDate;
    if (last == null) return;

    final diff = today.difference(last).inDays;
    if (diff == 1) {
      _userProgress!.currentStreak += 1;
      if (_userProgress!.currentStreak > _userProgress!.longestStreak) {
        _userProgress!.longestStreak = _userProgress!.currentStreak;
      }
    } else if (diff > 1) {
      _userProgress!.currentStreak = 1;
    }
    _userProgress!.lastActiveDate = today;
    _db.saveUserProgress(_userProgress!);
  }

  void _generateDailyLesson() {
    if (_words.isEmpty) return;
    final unlearned = _words.where((w) => !w.isLearned).take(5).toList();
    _dailyLesson = DailyLesson(
      id: 'daily_${DateTime.now().day}',
      languageId: _selectedLanguage!.id,
      title: 'Today\'s Lesson',
      description: 'Learn 5 new words today!',
      words: unlearned.isNotEmpty ? unlearned : _words.take(5).toList(),
      xpReward: 50,
    );
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> toggleFavorite(WordModel word) async {
    final index = _words.indexWhere((w) => w.id == word.id);
    if (index == -1) return;
    _words[index] = _words[index].copyWith(isFavorite: !_words[index].isFavorite);
    await _db.saveWordProgress(_words[index]);
    notifyListeners();
  }

  Future<void> markWordLearned(WordModel word) async {
    final index = _words.indexWhere((w) => w.id == word.id);
    if (index == -1) return;
    if (!_words[index].isLearned) {
      _words[index] = _words[index].copyWith(isLearned: true, reviewCount: _words[index].reviewCount + 1);
      await _db.saveWordProgress(_words[index]);

      // Update progress
      _userProgress ??= UserProgress(languageId: _selectedLanguage!.id);
      _userProgress!.wordsLearned += 1;
      _userProgress!.totalXP += 10;
      _userProgress!.lastActiveDate = DateTime.now();
      await _db.saveUserProgress(_userProgress!);

      await _checkAchievements();
      notifyListeners();
    }
  }

  Future<void> saveQuizResult(QuizResult result) async {
    await _db.saveQuizResult(result);
    _quizHistory.insert(0, result);

    _userProgress ??= UserProgress(languageId: _selectedLanguage!.id);
    _userProgress!.quizzesTaken += 1;
    _userProgress!.totalXP += result.correctAnswers * 15;
    _userProgress!.lastActiveDate = DateTime.now();
    await _db.saveUserProgress(_userProgress!);

    await _checkAchievements();
    notifyListeners();
  }

  Future<void> completeDailyLesson() async {
    _dailyLesson?.isCompleted = true;
    _userProgress ??= UserProgress(languageId: _selectedLanguage!.id);
    _userProgress!.totalXP += _dailyLesson?.xpReward ?? 50;
    await _db.saveUserProgress(_userProgress!);
    notifyListeners();
  }

  Future<void> _checkAchievements() async {
    final unlocked = <String>[];
    if (_userProgress!.wordsLearned >= 1 && !_unlockedAchievements.contains('first_word')) {
      unlocked.add('first_word');
    }
    if (_userProgress!.wordsLearned >= 10 && !_unlockedAchievements.contains('ten_words')) {
      unlocked.add('ten_words');
    }
    if (_userProgress!.quizzesTaken >= 1 && !_unlockedAchievements.contains('first_quiz')) {
      unlocked.add('first_quiz');
    }
    if (_userProgress!.currentStreak >= 3 && !_unlockedAchievements.contains('streak_3')) {
      unlocked.add('streak_3');
    }
    if (_userProgress!.currentStreak >= 7 && !_unlockedAchievements.contains('streak_7')) {
      unlocked.add('streak_7');
    }

    for (final id in unlocked) {
      await _db.unlockAchievement(id);
      _unlockedAchievements.add(id);
    }
  }

  List<QuizQuestion> getQuizQuestions(String category) {
    if (_selectedLanguage == null) return [];
    return SampleData.getQuizQuestions(_selectedLanguage!.id, category);
  }

  double get overallProgress {
    if (_words.isEmpty) return 0;
    return learnedWords.length / _words.length;
  }

  String get levelTitle {
    final xp = _userProgress?.totalXP ?? 0;
    if (xp < 100) return 'Beginner';
    if (xp < 300) return 'Elementary';
    if (xp < 600) return 'Intermediate';
    if (xp < 1000) return 'Advanced';
    return 'Expert';
  }
}