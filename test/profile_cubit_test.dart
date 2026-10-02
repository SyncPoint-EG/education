import 'dart:convert';

import 'package:education/core/services/storage_service.dart';
import 'package:education/features/profile/data/models/user_model.dart';
import 'package:education/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryStorageService implements StorageService {
  final Map<String, String> values = {};

  @override
  Future<void> init() async {}

  @override
  String? getString(String key) => values[key];

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }

  @override
  Future<void> clear() async {
    values.clear();
  }
}

void main() {
  test(
    'saves all level stars while milestone celebrations are pending',
    () async {
      final storage = _MemoryStorageService();
      final cubit = ProfileCubit(storage);
      addTearDown(cubit.close);

      await cubit.createUser('Tester', '🐧');

      // Complete in reverse map order, matching manual testing from the newest
      // sessions down to the oldest ones. This crosses multiple milestones.
      for (var levelId = 16; levelId >= 1; levelId--) {
        await cubit.completeLevel(levelId, 3);
      }

      final state = cubit.state;
      expect(state, isA<ProfileMilestoneUnlocked>());
      final user = (state as ProfileMilestoneUnlocked).user;
      expect(user.completedLevels, hasLength(16));
      for (var levelId = 1; levelId <= 16; levelId++) {
        expect(
          user.completedLevels[levelId]?.stars,
          3,
          reason: 'level $levelId',
        );
      }

      final savedUser = UserModel.fromJson(
        jsonDecode(storage.getString('user')!) as Map<String, dynamic>,
      );
      expect(savedUser.completedLevels, hasLength(16));
    },
  );
}
