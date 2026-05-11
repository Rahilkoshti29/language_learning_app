// lib/core/providers/app_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:language_learning_app/models.dart';
import 'package:language_learning_app/sample_data.dart';
import 'package:language_learning_app/database_service.dart';
import 'package:language_learning_app/auth_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  // ─── State ────────────────────────────────────────────────────────────────

  LanguageModel? _selectedLanguage;
  LanguageModel? get selectedLanguage => _selectedLanguage;

  List<WordModel> _words = [];
  List<WordModel> get words => _words;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  List<WordModel> get filteredWords =>
      _selectedCategory == 'All' ? _words : _words.where((w) => w.category == _selectedCategory).toList();

  List<WordModel> get favoriteWords => _words.where((w) => w.isFavorite).toList();
  List<WordModel> get learnedWords  => _words.where((w) => w.isLearned).toList();

  UserProgress? _userProgress;
  UserProgress? get userProgress => _userProgress;

  List<Achievement> _achievements = List.from(SampleData.achievements);
  List<Achievement> get achievements => _achievements;

  DailyLesson? _dailyLesson;
  DailyLesson? get dailyLesson => _dailyLesson;
  bool get isDailyLessonCompleted => _dailyLesson?.isCompleted ?? false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasCompletedOnboarding = false;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  // ─── Init ─────────────────────────────────────────────────────────────────

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding = prefs.getBool('onboarding_done') ?? false;
    await AuthService().loadFromPrefs();

    // Restore previously selected language
    final savedLangId = prefs.getString('selected_language');
    if (savedLangId != null) {
      final lang = SampleData.languages.where((l) => l.id == savedLangId).firstOrNull;
      if (lang != null) await selectLanguage(lang);
    }

    final unlocked = await _db.getUnlockedAchievements();
    _achievements = SampleData.achievements
        .map((a) => Achievement(id: a.id, title: a.title, description: a.description, icon: a.icon, xpReward: a.xpReward, isUnlocked: unlocked.contains(a.id)))
        .toList();

    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  // ─── Language ─────────────────────────────────────────────────────────────

  Future<void> selectLanguage(LanguageModel language) async {
    _isLoading = true;
    notifyListeners();

    _selectedLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language.id);

    await _loadWords(language.id);
    await _loadProgress(language.id);
    _generateDailyLesson();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadWords(String languageId) async {
    List<WordModel> raw = switch (languageId) {
      'hindi'    => SampleData.getHindiWords(),
      'gujarati' => SampleData.getGujaratiWords(),
      _          => SampleData.getHindiWords(),
    };

    final progress = await _db.getWordProgressForLanguage(languageId);
    _words = raw.map((w) {
      final p = progress[w.id];
      if (p != null) {
        return w.copyWith(
          isFavorite: p['isFavorite'] == 1,
          isLearned:  p['isLearned']  == 1,
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
    final last  = _userProgress!.lastActiveDate;
    if (last == null) { _userProgress!.lastActiveDate = today; return; }
    final diff  = DateTime(today.year, today.month, today.day)
        .difference(DateTime(last.year, last.month, last.day))
        .inDays;
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

  // ─── Category ─────────────────────────────────────────────────────────────

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // ─── Words ────────────────────────────────────────────────────────────────

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
    if (_words[index].isLearned) return;

    _words[index] = _words[index].copyWith(isLearned: true, reviewCount: _words[index].reviewCount + 1);
    await _db.saveWordProgress(_words[index]);

    _userProgress ??= UserProgress(languageId: _selectedLanguage!.id);
    _userProgress!.wordsLearned  += 1;
    _userProgress!.totalXP       += 10;
    _userProgress!.lastActiveDate = DateTime.now();
    await _db.saveUserProgress(_userProgress!);

    await _checkAchievements();
    notifyListeners();
  }

  // ─── Quiz ─────────────────────────────────────────────────────────────────

  List<QuizQuestion> getQuizQuestions(String category) {
    if (_selectedLanguage == null) return [];
    return SampleData.getQuizQuestions(_selectedLanguage!.id, category);
  }

  Future<void> saveQuizResult(QuizResult result) async {
    await _db.saveQuizResult(result);

    _userProgress ??= UserProgress(languageId: _selectedLanguage!.id);
    _userProgress!.quizzesTaken  += 1;
    _userProgress!.totalXP       += result.correctAnswers * 15;
    _userProgress!.lastActiveDate = DateTime.now();
    await _db.saveUserProgress(_userProgress!);

    await _checkAchievements();
    notifyListeners();
  }

  // ─── Daily Lesson ─────────────────────────────────────────────────────────

  Future<void> completeDailyLesson() async {
    _dailyLesson?.isCompleted = true;
    _userProgress ??= UserProgress(languageId: _selectedLanguage!.id);
    _userProgress!.totalXP += _dailyLesson?.xpReward ?? 50;
    _userProgress!.lastActiveDate = DateTime.now();
    await _db.saveUserProgress(_userProgress!);
    notifyListeners();
  }

  // ─── Achievements ─────────────────────────────────────────────────────────

  Future<void> _checkAchievements() async {
    final unlockedIds = _achievements.where((a) => a.isUnlocked).map((a) => a.id).toSet();
    final toUnlock    = <String>[];

    void check(String id, bool condition) {
      if (condition && !unlockedIds.contains(id)) toUnlock.add(id);
    }

    check('first_word',    (_userProgress?.wordsLearned ?? 0) >= 1);
    check('ten_words',     (_userProgress?.wordsLearned ?? 0) >= 10);
    check('first_quiz',    (_userProgress?.quizzesTaken ?? 0) >= 1);
    check('streak_3',      (_userProgress?.currentStreak ?? 0) >= 3);
    check('streak_7',      (_userProgress?.currentStreak ?? 0) >= 7);

    for (final id in toUnlock) {
      await _db.unlockAchievement(id);
    }

    if (toUnlock.isNotEmpty) {
      _achievements = _achievements.map((a) => Achievement(
        id: a.id, title: a.title, description: a.description,
        icon: a.icon, xpReward: a.xpReward,
        isUnlocked: a.isUnlocked || toUnlock.contains(a.id),
      )).toList();
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  double get overallProgress {
    if (_words.isEmpty) return 0;
    return learnedWords.length / _words.length;
  }

  String get levelTitle {
    final xp = _userProgress?.totalXP ?? 0;
    if (xp < 100)  return 'Beginner 🌱';
    if (xp < 300)  return 'Elementary 📗';
    if (xp < 600)  return 'Intermediate 📘';
    if (xp < 1000) return 'Advanced 📙';
    return 'Expert 🏆';
  }
}
 