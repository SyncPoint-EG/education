import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.name,
    required super.avatar,
    required super.gold,
    required super.gems,
    super.totalStars,
    super.unlockedMilestones,
    required super.currentLevel,
    required super.completedLevels,
    required super.totalSessions,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final Map<int, CompletedLevel> levelsMap = {};
    if (json['completedLevels'] != null) {
      final Map<String, dynamic> rawLevels = json['completedLevels'] as Map<String, dynamic>;
      rawLevels.forEach((key, value) {
        final levelId = int.tryParse(key);
        if (levelId != null && value is Map<String, dynamic>) {
          levelsMap[levelId] = CompletedLevel(
            stars: value['stars'] as int? ?? 0,
            completed: value['completed'] as bool? ?? false,
          );
        }
      });
    }

    // Parse unlocked milestones
    final List<String> milestones = [];
    if (json['unlockedMilestones'] != null) {
      for (final m in (json['unlockedMilestones'] as List)) {
        milestones.add(m.toString());
      }
    }

    return UserModel(
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '🐸',
      gold: json['gold'] as int? ?? 0,
      gems: json['gems'] as int? ?? 0,
      totalStars: json['totalStars'] as int? ?? 0,
      unlockedMilestones: milestones,
      currentLevel: json['currentLevel'] as int? ?? 1,
      completedLevels: levelsMap,
      totalSessions: json['totalSessions'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> levelsJson = {};
    completedLevels.forEach((key, value) {
      levelsJson[key.toString()] = {
        'stars': value.stars,
        'completed': value.completed,
      };
    });

    return {
      'name': name,
      'avatar': avatar,
      'gold': gold,
      'gems': gems,
      'totalStars': totalStars,
      'unlockedMilestones': unlockedMilestones,
      'currentLevel': currentLevel,
      'completedLevels': levelsJson,
      'totalSessions': totalSessions,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      name: entity.name,
      avatar: entity.avatar,
      gold: entity.gold,
      gems: entity.gems,
      totalStars: entity.totalStars,
      unlockedMilestones: entity.unlockedMilestones,
      currentLevel: entity.currentLevel,
      completedLevels: entity.completedLevels,
      totalSessions: entity.totalSessions,
      createdAt: entity.createdAt,
    );
  }
}
