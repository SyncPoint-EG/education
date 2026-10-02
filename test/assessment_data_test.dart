import 'package:education/features/map/data/datasources/levels_data.dart';
import 'package:education/features/map/domain/entities/level_entity.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('session 15 uses audio matching and the supplied body-parts board', () {
    final session = LevelsData.levels[14];
    expect(session.title, 'أجزاء جسمي');

    final audioMatch = session.assessmentActivities.first;
    expect(audioMatch.audioOnlyOptions, isTrue);
    expect(audioMatch.imagePaths, isNull);
    expect(audioMatch.audioPaths, [
      'assets/audio/body_part_nose.m4a',
      'assets/audio/body_part_eye.m4a',
    ]);

    final bodyPartsBuilder = session.assessmentActivities[1];
    expect(bodyPartsBuilder.type, AssessmentGameType.bodyPartsBuilder);
    expect(bodyPartsBuilder.options, hasLength(10));
    expect(bodyPartsBuilder.imagePaths, hasLength(10));
    expect(
      bodyPartsBuilder.iconPath,
      'assets/image/body_parts_board_empty.jpeg',
    );
    expect(bodyPartsBuilder.mergedTargetImagePaths, [
      'assets/image/body_parts_board_complete.jpeg',
    ]);
  });

  test('session 1 work pictures match their labels', () async {
    final workMatching = LevelsData.levels.first.assessmentActivities[1];

    expect(workMatching.options, [
      'الكنس',
      'المذاكرة',
      'الطبخ',
      'الغسيل',
      'تصليح السيارات',
      'السباكة',
    ]);
    expect(workMatching.imagePaths, [
      'assets/image/mother_task_cooking.jpg',
      'assets/image/mother_task_homework.jpg',
      'assets/image/mother_task_cooking_correct.png',
      'assets/image/mother_task_laundry_correct.png',
      'assets/image/mother_task_car.jpg',
      'assets/image/mother_task_laundry.jpg',
    ]);
    expect(workMatching.correctTargetIndexes, [0, 0, 0, 0, 1, 1]);

    for (final path in workMatching.imagePaths!) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(0), reason: path);
    }
  });

  test('all session 15 media load from the Flutter asset bundle', () async {
    final session = LevelsData.levels[14];
    final audioMatch = session.assessmentActivities.first;
    final bodyPartsBuilder = session.assessmentActivities[1];
    final assetPaths = <String>{
      ...audioMatch.targetImagePaths!,
      ...audioMatch.audioPaths!,
      ...bodyPartsBuilder.imagePaths!,
      bodyPartsBuilder.iconPath!,
      ...bodyPartsBuilder.mergedTargetImagePaths!,
    };

    for (final path in assetPaths) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(0), reason: path);
    }
  });

  test('shape balloons use the four supplied videos', () async {
    final activity = LevelsData.levels[13].assessmentActivities.first;
    expect(activity.type, AssessmentGameType.shapeBalloons);
    expect(activity.videoPaths, [
      'assets/vedios/shape_balloon_square.mp4',
      'assets/vedios/shape_balloon_triangle.mp4',
      'assets/vedios/shape_balloon_rectangle.mp4',
      'assets/vedios/shape_balloon_circle.mp4',
    ]);

    for (final path in activity.videoPaths!) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(0), reason: path);
    }
  });

  test('session 16 uses the supplied privacy marker board', () async {
    final activity = LevelsData.levels[15].assessmentActivities.first;
    expect(activity.type, AssessmentGameType.bodyPrivacyMarkers);
    expect(activity.targets, hasLength(7));
    expect(activity.correctTargetIndexes, [1, 1, 1, 0, 0, 0, 0]);
    expect(activity.iconPath, 'assets/image/privacy_body_board_empty.jpeg');
    expect(activity.imagePaths, [
      'assets/image/privacy_marker_wrong.jpeg',
      'assets/image/privacy_marker_correct.jpeg',
    ]);

    final assetPaths = <String>{
      activity.iconPath!,
      ...activity.imagePaths!,
      ...activity.mergedTargetImagePaths!,
    };
    for (final path in assetPaths) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(0), reason: path);
    }
  });

  test('five senses song opens only the supplied video', () async {
    final activity = LevelsData.levels[12].assessmentActivities[1];
    expect(activity.type, AssessmentGameType.songRepeat);
    expect(activity.prompt, 'ردد كلمات الاغنيه معايا');
    expect(activity.options, isEmpty);
    expect(activity.audioPaths, isNull);
    expect(activity.videoUrl, 'assets/vedios/VIDEO-2026-08-26-17-08-14.mp4');

    final data = await rootBundle.load(activity.videoUrl!);
    expect(data.lengthInBytes, greaterThan(0));
  });

  test('animal family matching uses adult and young supplied images', () async {
    final session = LevelsData.levels[1];
    final soundMatching = session.assessmentActivities.first;
    final familyMatching = session.assessmentActivities[1];

    expect(soundMatching.audioPaths, [
      'assets/audio/cat.m4a',
      'assets/audio/cow.m4a',
    ]);
    expect(familyMatching.audioPaths, [
      'assets/audio/cat.m4a',
      'assets/audio/cow.m4a',
    ]);
    expect(soundMatching.targetImagePaths, [
      'assets/image/animal_cat_adult_new.jpeg',
      'assets/image/animal_cow_adult_new.jpeg',
    ]);
    expect(familyMatching.imagePaths, [
      'assets/image/animal_kitten_new.jpeg',
      'assets/image/animal_calf_new.jpeg',
    ]);
    expect(familyMatching.targetImagePaths, [
      'assets/image/animal_cat_adult_new.jpeg',
      'assets/image/animal_cow_adult_new.jpeg',
    ]);
    expect(familyMatching.mergedTargetImagePaths, [
      'assets/image/animal_cat_family_new.jpeg',
    ]);

    final paths = <String>{
      ...soundMatching.audioPaths!,
      ...familyMatching.audioPaths!,
      ...soundMatching.targetImagePaths!,
      ...familyMatching.imagePaths!,
      ...familyMatching.targetImagePaths!,
      ...familyMatching.mergedTargetImagePaths!,
    };
    for (final path in paths) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(0), reason: path);
    }
  });

  test(
    'goat and chicken matching uses adult and young supplied images',
    () async {
      final session = LevelsData.levels[2];
      final soundMatching = session.assessmentActivities.first;
      final familyMatching = session.assessmentActivities[1];

      expect(soundMatching.targetImagePaths, [
        'assets/image/animal_chicken_adult_new.jpeg',
        'assets/image/animal_goat_adult_new.jpeg',
      ]);
      expect(familyMatching.imagePaths, [
        'assets/image/animal_goat_kid_new.jpeg',
        'assets/image/animal_chick_new.jpeg',
      ]);
      expect(familyMatching.targetImagePaths, [
        'assets/image/animal_goat_adult_new.jpeg',
        'assets/image/animal_chicken_adult_new.jpeg',
      ]);
      expect(familyMatching.mergedTargetImagePaths, [
        'assets/image/animal_goat_family_new.jpeg',
        'assets/image/animal_chicken_family_new.jpeg',
      ]);

      final paths = <String>{
        ...soundMatching.targetImagePaths!,
        ...familyMatching.imagePaths!,
        ...familyMatching.targetImagePaths!,
        ...familyMatching.mergedTargetImagePaths!,
      };
      for (final path in paths) {
        final data = await rootBundle.load(path);
        expect(data.lengthInBytes, greaterThan(0), reason: path);
      }
    },
  );

  test('cow and goat use different sound files', () async {
    final cowData = await rootBundle.load('assets/audio/cow.m4a');
    final goatData = await rootBundle.load('assets/audio/goat.m4a');
    final cowBytes = cowData.buffer.asUint8List();
    final goatBytes = goatData.buffer.asUint8List();

    expect(cowBytes, isNot(orderedEquals(goatBytes)));
  });

  test('session 12 conveyor uses the supplied beetroot image', () async {
    final conveyor = LevelsData.levels[11].assessmentActivities.first;
    final beetrootIndex = conveyor.options.indexOf('بنجر');

    expect(beetrootIndex, greaterThanOrEqualTo(0));
    expect(conveyor.imagePaths, hasLength(conveyor.options.length));
    expect(conveyor.imagePaths![beetrootIndex], 'assets/image/beetroot.jpeg');

    final data = await rootBundle.load(conveyor.imagePaths![beetrootIndex]);
    expect(data.lengthInBytes, greaterThan(0));
  });

  test('sessions 7 through 16 expose the requested interactive activities', () {
    expect(LevelsData.levels, hasLength(16));

    final types = LevelsData.levels
        .skip(6)
        .expand((level) => level.assessmentActivities)
        .map((activity) => activity.type)
        .toSet();

    expect(types, contains(AssessmentGameType.selectMany));
    expect(types, contains(AssessmentGameType.colorMix));
    expect(types, contains(AssessmentGameType.coloring));
    expect(types, contains(AssessmentGameType.speechPicture));
    expect(types, contains(AssessmentGameType.balloonPop));
    expect(types, contains(AssessmentGameType.saladMaker));
    expect(types, contains(AssessmentGameType.conveyorSort));
    expect(types, contains(AssessmentGameType.memoryReveal));
    expect(types, contains(AssessmentGameType.songRepeat));
    expect(types, contains(AssessmentGameType.shapeBalloons));
    expect(types, contains(AssessmentGameType.traceShape));
    expect(types, contains(AssessmentGameType.faceBuilder));
    expect(types, contains(AssessmentGameType.sequenceTrain));
    expect(types, contains(AssessmentGameType.feeling));

    for (final level in LevelsData.levels.skip(6)) {
      expect(level.assessmentActivities, hasLength(3));
      expect(level.assessmentActivities.last.type, AssessmentGameType.feeling);
    }

    final fruitColoring = LevelsData.levels[8].assessmentActivities[1];
    expect(fruitColoring.targets, ['برتقالة', 'بطيخة', 'فراولة']);
    expect(fruitColoring.targets, isNot(contains('خوخة')));

    final senses = LevelsData.levels[12];
    expect(senses.title, 'الحواس الخمس');
    expect(senses.assessmentActivities.first.options, hasLength(7));
    expect(
      senses.assessmentActivities.first.correctOptionIndexes,
      hasLength(5),
    );

    expect(LevelsData.levels[13].title, 'الأشكال الهندسية');
    expect(LevelsData.levels[14].title, 'أجزاء جسمي');
    expect(LevelsData.levels[15].title, 'حماية جسمي');
    expect(LevelsData.levels[13].videoPath, isEmpty);
    expect(LevelsData.levels[14].videoPath, isEmpty);
    expect(LevelsData.levels[15].videoPath, isEmpty);

    final cowSound =
        LevelsData.levels[1].assessmentActivities.first.audioPaths![1];
    expect(cowSound, 'assets/audio/cow.m4a');
  });
}
