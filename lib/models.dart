// lib/core/models/language_model.dart

class LanguageModel {
  final String id;
  final String name;
  final String nativeName;
  final String flagEmoji;
  final String description;
  final int totalWords;
  final List<String> categories;

  const LanguageModel({
    required this.id,
    required this.name,
    required this.nativeName,
    required this.flagEmoji,
    required this.description,
    required this.totalWords,
    required this.categories,
  });
}

class WordModel {
  final String id;
  final String word;
  final String translation;
  final String transliteration;
  final String pronunciation;
  final String languageId;
  final String category;
  final String exampleSentence;
  final String exampleTranslation;
  final int difficulty; // 1=easy, 2=medium, 3=hard
  bool isFavorite;
  bool isLearned;
  int reviewCount;
  DateTime? nextReviewDate;

  WordModel({
    required this.id,
    required this.word,
    required this.translation,
    required this.transliteration,
    required this.pronunciation,
    required this.languageId,
    required this.category,
    required this.exampleSentence,
    required this.exampleTranslation,
    this.difficulty = 1,
    this.isFavorite = false,
    this.isLearned = false,
    this.reviewCount = 0,
    this.nextReviewDate,
  });

  WordModel copyWith({
    bool? isFavorite,
    bool? isLearned,
    int? reviewCount,
    DateTime? nextReviewDate,
  }) {
    return WordModel(
      id: id,
      word: word,
      translation: translation,
      transliteration: transliteration,
      pronunciation: pronunciation,
      languageId: languageId,
      category: category,
      exampleSentence: exampleSentence,
      exampleTranslation: exampleTranslation,
      difficulty: difficulty,
      isFavorite: isFavorite ?? this.isFavorite,
      isLearned: isLearned ?? this.isLearned,
      reviewCount: reviewCount ?? this.reviewCount,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'transliteration': transliteration,
      'pronunciation': pronunciation,
      'languageId': languageId,
      'category': category,
      'exampleSentence': exampleSentence,
      'exampleTranslation': exampleTranslation,
      'difficulty': difficulty,
      'isFavorite': isFavorite ? 1 : 0,
      'isLearned': isLearned ? 1 : 0,
      'reviewCount': reviewCount,
      'nextReviewDate': nextReviewDate?.toIso8601String(),
    };
  }

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'],
      word: map['word'],
      translation: map['translation'],
      transliteration: map['transliteration'],
      pronunciation: map['pronunciation'],
      languageId: map['languageId'],
      category: map['category'],
      exampleSentence: map['exampleSentence'],
      exampleTranslation: map['exampleTranslation'],
      difficulty: map['difficulty'] ?? 1,
      isFavorite: map['isFavorite'] == 1,
      isLearned: map['isLearned'] == 1,
      reviewCount: map['reviewCount'] ?? 0,
      nextReviewDate: map['nextReviewDate'] != null
          ? DateTime.parse(map['nextReviewDate'])
          : null,
    );
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String languageId;
  final String category;
  final QuizType type;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.languageId,
    required this.category,
    required this.type,
  });
}

enum QuizType { multipleChoice, trueFalse, fillBlank, matchPair }

class QuizResult {
  final String languageId;
  final String category;
  final int totalQuestions;
  final int correctAnswers;
  final Duration timeTaken;
  final DateTime completedAt;

  QuizResult({
    required this.languageId,
    required this.category,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeTaken,
    required this.completedAt,
  });

  double get scorePercent => (correctAnswers / totalQuestions) * 100;

  Map<String, dynamic> toMap() {
    return {
      'languageId': languageId,
      'category': category,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'timeTaken': timeTaken.inSeconds,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}

class UserProgress {
  final String languageId;
  int wordsLearned;
  int quizzesTaken;
  int currentStreak;
  int longestStreak;
  int totalXP;
  DateTime? lastActiveDate;
  Map<String, int> categoryProgress; // category -> words learned

  UserProgress({
    required this.languageId,
    this.wordsLearned = 0,
    this.quizzesTaken = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalXP = 0,
    this.lastActiveDate,
    Map<String, int>? categoryProgress,
  }) : categoryProgress = categoryProgress ?? {};

  Map<String, dynamic> toMap() {
    return {
      'languageId': languageId,
      'wordsLearned': wordsLearned,
      'quizzesTaken': quizzesTaken,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalXP': totalXP,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
    };
  }
}

class DailyLesson {
  final String id;
  final String languageId;
  final String title;
  final String description;
  final List<WordModel> words;
  final int xpReward;
  bool isCompleted;

  DailyLesson({
    required this.id,
    required this.languageId,
    required this.title,
    required this.description,
    required this.words,
    required this.xpReward,
    this.isCompleted = false,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int xpReward;
  final bool isUnlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    this.isUnlocked = false,
  });
}