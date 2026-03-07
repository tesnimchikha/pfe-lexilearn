import 'package:shared_preferences/shared_preferences.dart';

class UserProgress {
  static const String _scoreKey = 'user_total_score';
  static const String _levelKey = 'user_level';
  static const String _trophiesKey = 'user_trophies';

  // Calculate level based on score: 300 points = 1 level
  static int calculateLevel(int score) {
    return (score ~/ 300);
  }

  // Get points needed for next level
  static int pointsForNextLevel(int currentLevel) {
    return (currentLevel + 1) * 300;
  }

  // Get progress percentage (0.0 to 1.0)
  static double progressPercentage(int totalScore, int level) {
    int currentLevelMinPoints = level * 300;
    int pointsInCurrentLevel = totalScore - currentLevelMinPoints;
    return pointsInCurrentLevel / 300.0;
  }

  // Add score and check for level up
  static Future<Map<String, dynamic>> addScore(int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    
    int currentScore = prefs.getInt(_scoreKey) ?? 0;
    int newTotalScore = currentScore + newScore;
    int oldLevel = calculateLevel(currentScore);
    int newLevel = calculateLevel(newTotalScore);
    
    List<String> trophies = prefs.getStringList(_trophiesKey) ?? [];
    bool leveledUp = false;
    
    // Check if leveled up
    if (newLevel > oldLevel) {
      leveledUp = true;
      for (int i = oldLevel + 1; i <= newLevel; i++) {
        trophies.add('Level $i Cup 🏆');
      }
    }
    
    // Save data
    await prefs.setInt(_scoreKey, newTotalScore);
    await prefs.setInt(_levelKey, newLevel);
    await prefs.setStringList(_trophiesKey, trophies);
    
    return {
      'totalScore': newTotalScore,
      'level': newLevel,
      'trophies': trophies,
      'leveledUp': leveledUp,
      'pointsToNextLevel': pointsForNextLevel(newLevel) - newTotalScore,
    };
  }

  // Get current progress
  static Future<Map<String, dynamic>> getCurrentProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    int score = prefs.getInt(_scoreKey) ?? 0;
    int level = calculateLevel(score);
    List<String> trophies = prefs.getStringList(_trophiesKey) ?? [];
    
    return {
      'totalScore': score,
      'level': level,
      'trophies': trophies,
      'nextLevelPoints': pointsForNextLevel(level) - score,
      'progressPercentage': progressPercentage(score, level),
    };
  }

  // Reset progress (for testing)
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scoreKey);
    await prefs.remove(_levelKey);
    await prefs.remove(_trophiesKey);
  }
}