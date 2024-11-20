import 'Parent/UserService.dart';


class GameLogic {
  final UserService _userService = UserService();

  // Save game score after playing
  Future<void> saveGameScore({
    required String parentId,
    required String childId,
    required String gameName,
    required int score,
  }) async {
    await _userService.addGamePlayed(
      parentId: parentId,
      childId: childId,
      gameName: gameName,
      lastScore: score,
    );
  }

  // Fetch and initialize game data
  Future<void> fetchAndStartGame({
    required String parentId,
    required String childId,
    required String gameName,
  }) async {
    Map<String, dynamic>? gameData = await _userService.fetchGameData(
      parentId: parentId,
      childId: childId,
      gameName: gameName,
    );

    if (gameData != null) {
      print('Starting game with last score: ${gameData['lastScore']}');
    } else {
      print('Starting game with no prior data');
    }
  }

  // Display child progress
  Future<void> displayChildProgress({
    required String parentId,
    required String childId,
  }) async {
    List<Map<String, dynamic>> progressData = await _userService.fetchChildProgress(
      parentId: parentId,
      childId: childId,
    );

    for (var game in progressData) {
      print('Game: ${game['gameName']}');
      print('Last Score: ${game['lastScore']}');
      print('Total Score: ${game['totalScore']}');
      print('Attempts: ${game['attempts']}');
    }
  }
}
