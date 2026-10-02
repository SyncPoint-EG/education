import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/star_milestone.dart';
import '../../data/models/user_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUnauthenticated extends ProfileState {}

class ProfileAuthenticated extends ProfileState {
  final UserEntity user;
  ProfileAuthenticated(this.user);
}

/// Emitted when new milestones are unlocked after completing a level.
class ProfileMilestoneUnlocked extends ProfileState {
  final UserEntity user;
  final List<StarMilestone> newMilestones;
  ProfileMilestoneUnlocked(this.user, this.newMilestones);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileCubit extends Cubit<ProfileState> {
  final StorageService _storageService;
  static const _userKey = 'user';

  ProfileCubit(this._storageService) : super(ProfileInitial());

  Future<void> loadUser() async {
    emit(ProfileLoading());
    try {
      final userJson = _storageService.getString(_userKey);
      if (userJson == null) {
        emit(ProfileUnauthenticated());
      } else {
        final Map<String, dynamic> decoded = jsonDecode(userJson);
        final user = UserModel.fromJson(decoded);
        emit(ProfileAuthenticated(user));
      }
    } catch (e) {
      emit(ProfileError("فشل في تحميل بيانات المستخدم"));
    }
  }

  Future<void> createUser(String name, String avatar) async {
    emit(ProfileLoading());
    try {
      final newUser = UserModel(
        name: name,
        avatar: avatar,
        gold: 0,
        gems: 0,
        totalStars: 0,
        unlockedMilestones: [],
        currentLevel: 1,
        completedLevels: {},
        totalSessions: 0,
        createdAt: DateTime.now().toIso8601String().split('T')[0],
      );
      await _storageService.setString(_userKey, jsonEncode(newUser.toJson()));
      emit(ProfileAuthenticated(newUser));
    } catch (e) {
      emit(ProfileError("فشل في إنشاء الحساب"));
    }
  }

  Future<void> addGold(int amount) async {
    final currentState = state;
    if (currentState is ProfileAuthenticated) {
      final updatedUser = currentState.user.copyWith(
        gold: currentState.user.gold + amount,
      );
      await _saveAndEmit(updatedUser);
    }
  }

  Future<void> addGems(int amount) async {
    final currentState = state;
    if (currentState is ProfileAuthenticated) {
      final updatedUser = currentState.user.copyWith(
        gems: currentState.user.gems + amount,
      );
      await _saveAndEmit(updatedUser);
    }
  }

  Future<void> completeLevel(int levelId, int stars) async {
    final currentState = state;
    final user = switch (currentState) {
      ProfileAuthenticated(:final user) => user,
      ProfileMilestoneUnlocked(:final user) => user,
      _ => null,
    };

    if (user != null) {
      final pendingMilestones = currentState is ProfileMilestoneUnlocked
          ? currentState.newMilestones
          : const <StarMilestone>[];
      final completedLevels = Map<int, CompletedLevel>.from(
        user.completedLevels,
      );

      final prev = completedLevels[levelId];
      if (prev == null || prev.stars < stars) {
        completedLevels[levelId] = CompletedLevel(
          stars: stars,
          completed: true,
        );
      }

      int nextLevel = user.currentLevel;
      if (levelId >= user.currentLevel) {
        nextLevel = levelId + 1;
      }

      // Reward
      int goldReward = stars * 10;
      int gemReward = (stars == 3) ? 1 : 0;

      // Accumulate total stars
      final int newTotalStars = user.totalStars + stars;

      // Check for newly unlocked milestones
      final newMilestones = checkNewMilestones(
        newTotalStars,
        user.unlockedMilestones,
      );

      // Update unlocked milestones list
      final updatedMilestones = List<String>.from(user.unlockedMilestones);
      for (final m in newMilestones) {
        updatedMilestones.add(m.id);
      }

      // Bonus rewards for unlocking milestones
      int milestoneGoldBonus = newMilestones.length * 25;
      int milestoneGemBonus = newMilestones.length;

      final updatedUser = user.copyWith(
        completedLevels: completedLevels,
        currentLevel: nextLevel,
        totalSessions: user.totalSessions + 1,
        gold: user.gold + goldReward + milestoneGoldBonus,
        gems: user.gems + gemReward + milestoneGemBonus,
        totalStars: newTotalStars,
        unlockedMilestones: updatedMilestones,
      );

      await _saveUser(updatedUser);

      // Keep any celebration pending while still allowing later level results
      // to be saved. Some game flows return directly to the map and do not
      // acknowledge the milestone state before the next level is completed.
      final milestonesToShow = <StarMilestone>[
        ...pendingMilestones,
        ...newMilestones,
      ];
      if (milestonesToShow.isNotEmpty) {
        emit(ProfileMilestoneUnlocked(updatedUser, milestonesToShow));
      } else {
        emit(ProfileAuthenticated(updatedUser));
      }
    }
  }

  /// After showing the milestone celebration, call this to go back
  /// to normal authenticated state.
  void acknowledgeMilestones() {
    final currentState = state;
    if (currentState is ProfileMilestoneUnlocked) {
      emit(ProfileAuthenticated(currentState.user));
    }
  }

  Future<void> resetUser() async {
    emit(ProfileLoading());
    try {
      await _storageService.remove(_userKey);
      emit(ProfileUnauthenticated());
    } catch (e) {
      emit(ProfileError("فشل في مسح البيانات"));
    }
  }

  Future<void> _saveAndEmit(UserEntity user) async {
    await _saveUser(user);
    emit(ProfileAuthenticated(user));
  }

  Future<void> _saveUser(UserEntity user) async {
    final model = UserModel.fromEntity(user);
    await _storageService.setString(_userKey, jsonEncode(model.toJson()));
  }
}
