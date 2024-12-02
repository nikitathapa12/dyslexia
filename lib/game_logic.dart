import 'Parent/user_service.dart';

class GameLogic {
  final UserService _userService = UserService();

  // Save game score after playing
  Future<void> saveGameScore({
    required String childId,
    required String gameName,
    required int score,
    required int totalScore,
    required int attempts,
  }) async {
    await _userService.addGameProgress(
      childId: childId,
      gameName: gameName,
      lastScore: score,
      totalScore: totalScore,
      attempts: attempts,
    );
  }

  // Fetch and initialize game data
  Future<void> fetchAndStartGame({
    required String childId,
    required String gameName,
  }) async {
    List<Map<String, dynamic>> gameData = await _userService.fetchChildProgress(
      childId: childId,
    );

    bool found = false;
    for (var game in gameData) {
      if (game['gameName'] == gameName) {
        print('Starting game with last score: ${game['lastScore']}');
        found = true;
        break;
      }
    }
    if (!found) {
      print('Starting game with no prior data');
    }
  }

  // Display child progress
  Future<void> displayChildProgress({
    required String childId,
  }) async {
    List<Map<String, dynamic>> progressData = await _userService.fetchChildProgress(
      childId: childId,
    );

    if (progressData.isNotEmpty) {
      for (var game in progressData) {
        print('Game: ${game['gameName']}');
        print('Last Score: ${game['lastScore']}');
        print('Total Score: ${game['totalScore']}');
        print('Attempts: ${game['attempts']}');
      }
    } else {
      print('No progress data available.');
    }
  }
}
