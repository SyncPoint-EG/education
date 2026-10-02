enum ExerciseType { listenRepeat, describeImage, answerQuestion }

enum AssessmentGameType {
  chooseCard,
  dragToTarget,
  feeling,
  selectMany,
  colorMix,
  coloring,
  speechPicture,
  balloonPop,
  conveyorSort,
  saladMaker,
  memoryReveal,
  songRepeat,
  shapeBalloons,
  traceShape,
  faceBuilder, // keep faceBuilder in case other levels use it
  bodyPartsBuilder,
  bodyPrivacyMarkers,
  sequenceTrain,
  puzzle,
  cameraIdentity,
  nameAndGender,
}

class ExerciseEntity {
  final String id;
  final ExerciseType type;
  final String prompt;
  final String? word;
  final String image;
  final String? hint;
  final List<String>? expectedWords;
  final String? expectedAnswer;

  ExerciseEntity({
    required this.id,
    required this.type,
    required this.prompt,
    this.word,
    required this.image,
    this.hint,
    this.expectedWords,
    this.expectedAnswer,
  });
}

class AssessmentActivityEntity {
  final String prompt;
  final AssessmentGameType type;
  final String emoji;
  final String? iconPath; // Optional path for image instead of emoji
  final List<String> options;
  final List<String>? audioPaths; // Optional parallel list to options
  final List<String>?
  imagePaths; // Optional parallel list to options for images
  final bool audioOnlyOptions; // Show draggable choices as speaker buttons only
  final List<String> targets;
  final List<String>?
  targetImagePaths; // Optional parallel list to targets for images
  final List<String>?
  mergedTargetImagePaths; // Shown after a target is successfully matched
  final List<int> correctTargetIndexes;
  final int? correctOptionIndex;
  final List<int> correctOptionIndexes;
  final List<int> colorValues;
  final String? videoUrl; // Optional video URL (e.g. YouTube)
  final List<String>? videoPaths; // Optional parallel videos for options
  final String successMessage;

  const AssessmentActivityEntity({
    required this.prompt,
    required this.type,
    required this.emoji,
    this.iconPath,
    required this.options,
    this.audioPaths,
    this.imagePaths,
    this.audioOnlyOptions = false,
    this.targets = const [],
    this.targetImagePaths,
    this.mergedTargetImagePaths,
    this.correctTargetIndexes = const [],
    this.correctOptionIndex,
    this.correctOptionIndexes = const [],
    this.colorValues = const [],
    this.videoUrl,
    this.videoPaths,
    required this.successMessage,
  });
}

class LevelEntity {
  final int id;
  final String title;
  final String emoji;
  final String colorCode;
  final String bgColorCode;
  final List<ExerciseEntity> exercises;

  /// Mini games shown after the learning video ends.
  final List<AssessmentActivityEntity> assessmentActivities;

  /// Asset path of the video shown before this level's game session.
  final String videoPath;

  LevelEntity({
    required this.id,
    required this.title,
    required this.emoji,
    required this.colorCode,
    required this.bgColorCode,
    required this.exercises,
    required this.assessmentActivities,
    required this.videoPath,
  });
}
