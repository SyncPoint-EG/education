import '../../domain/entities/level_entity.dart';

class LevelsData {
  // ─────────────────────────────────────────────────────────────────────────
  // 1. List of available video assets.
  //    To add a new level, just add its video path here.
  // ─────────────────────────────────────────────────────────────────────────
  static const List<String> videoPaths = [
    'assets/vedios/01_family.mp4', // Session 1
    'assets/vedios/02_animals.mp4', // Session 2
    'assets/vedios/03_animals.mp4', // Session 3
    'assets/vedios/04_who_am_i.mp4', // Session 4
    'assets/vedios/05_transportation_1.mp4', // Session 5
    'assets/vedios/06_transportation_2.mp4', // Session 6
    'assets/vedios/07_colors_1.mp4', // Session 7
    'assets/vedios/08_colors_2.mp4', // Session 8
    'assets/vedios/09_fruits_1.mp4', // Session 9
    'assets/vedios/10_fruits_2.mp4', // Session 10
    'assets/vedios/11_salad_1.mp4', // Session 11
    'assets/vedios/12_salad_2.mp4', // Session 12
    'assets/vedios/13_five_senses.mp4', // Session 13
    'assets/vedios/14_shapes.mp4', // Session 14
    'assets/vedios/15_body_parts.mp4', // Session 15
    'assets/vedios/16_body_protection.mp4', // Session 16
  ];

  static const List<List<AssessmentActivityEntity>> assessmentActivities = [
    [
      AssessmentActivityEntity(
        prompt: 'اسحب الملابس للشخصية المناسبة',
        type: AssessmentGameType.dragToTarget,
        emoji: '👩',
        iconPath: 'assets/image/new_mother.jpg',
        options: ['فستان الأم', 'ملابس الأم', 'بدلة الأب', 'جلابية الأب'],
        imagePaths: [
          'assets/image/new_mother_dress.jpg',
          'assets/image/new_mother_casual.jpg',
          'assets/image/new_father_suit.jpg',
          'assets/image/new_father_thobe.jpg',
        ],
        targets: ['الأم', 'الأب'],
        targetImagePaths: [
          'assets/image/new_mother.jpg',
          'assets/image/new_father.jpg',
        ],
        correctTargetIndexes: [0, 0, 1, 1],
        successMessage: 'برافو! لبست الأسرة صح.',
      ),

      AssessmentActivityEntity(
        prompt: 'وصل العمل بصاحبه',
        type: AssessmentGameType.dragToTarget,
        emoji: '🏠',
        options: [
          'الكنس',
          'المذاكرة',
          'الطبخ',
          'الغسيل',
          'تصليح السيارات',
          'السباكة',
        ],
        imagePaths: [
          'assets/image/mother_task_cooking.jpg',
          'assets/image/mother_task_homework.jpg',
          'assets/image/mother_task_cooking_correct.png',
          'assets/image/mother_task_laundry_correct.png',
          'assets/image/mother_task_car.jpg',
          'assets/image/mother_task_laundry.jpg',
        ],
        targets: ['دور الأم في البيت', 'عمل آخر'],
        targetImagePaths: [
          'assets/image/new_mother.jpg',
          'assets/image/new_father.jpg',
        ],
        correctTargetIndexes: [0, 0, 0, 0, 1, 1],
        successMessage: 'ممتاز! عرفت دور الأم في المنزل.',
      ),
    ],
    [
      AssessmentActivityEntity(
        prompt: 'وصل الصوت بالحيوان الصحيح',
        type: AssessmentGameType.dragToTarget,
        emoji: '🐄',
        iconPath: 'assets/image/animal_cow_adult_new.jpeg',
        options: ['مياو', 'موو'],
        audioPaths: ['assets/audio/cat.m4a', 'assets/audio/cow.m4a'],
        targets: ['القطة', 'البقرة'],
        targetImagePaths: [
          'assets/image/animal_cat_adult_new.jpeg',
          'assets/image/animal_cow_adult_new.jpeg',
        ],
        correctTargetIndexes: [0, 1],
        successMessage: 'رائع! سمعت الأصوات صح.',
      ),

      AssessmentActivityEntity(
        prompt: 'وصل الحيوان بصغيره',
        type: AssessmentGameType.dragToTarget,
        emoji: '🐱',
        iconPath: 'assets/image/animal_cat_adult_new.jpeg',
        options: ['قطقوط', 'عجل'],
        audioPaths: ['assets/audio/cat.m4a', 'assets/audio/cow.m4a'],
        imagePaths: [
          'assets/image/animal_kitten_new.jpeg',
          'assets/image/animal_calf_new.jpeg',
        ],
        targets: ['قطة', 'بقرة'],
        targetImagePaths: [
          'assets/image/animal_cat_adult_new.jpeg',
          'assets/image/animal_cow_adult_new.jpeg',
        ],
        mergedTargetImagePaths: ['assets/image/animal_cat_family_new.jpeg'],
        correctTargetIndexes: [0, 1],
        successMessage: 'تمام! عرفت الحيوان وصغيره.',
      ),
    ],
    [
      AssessmentActivityEntity(
        prompt: 'وصل الصوت بالحيوان الصحيح',
        type: AssessmentGameType.dragToTarget,
        emoji: '🐔',
        iconPath: 'assets/image/animal_chicken_adult_new.jpeg',
        options: ['كوكو', 'ماااع'],
        audioPaths: ['assets/audio/chicken.m4a', 'assets/audio/goat.m4a'],
        targets: ['الدجاجة', 'الماعز'],
        targetImagePaths: [
          'assets/image/animal_chicken_adult_new.jpeg',
          'assets/image/animal_goat_adult_new.jpeg',
        ],
        correctTargetIndexes: [0, 1],
        successMessage: 'أحسنت! الأصوات صحيحة.',
      ),
      AssessmentActivityEntity(
        prompt: 'وصل الحيوان بصغيره',
        type: AssessmentGameType.dragToTarget,
        emoji: '🐐',
        iconPath: 'assets/image/animal_goat_adult_new.jpeg',
        options: ['جدي', 'كتكوت'],
        audioPaths: ['ماعز م م ماعز', 'دجاجة د د دجاجة'],
        imagePaths: [
          'assets/image/animal_goat_kid_new.jpeg',
          'assets/image/animal_chick_new.jpeg',
        ],
        targets: ['ماعز', 'دجاجة'],
        targetImagePaths: [
          'assets/image/animal_goat_adult_new.jpeg',
          'assets/image/animal_chicken_adult_new.jpeg',
        ],
        mergedTargetImagePaths: [
          'assets/image/animal_goat_family_new.jpeg',
          'assets/image/animal_chicken_family_new.jpeg',
        ],
        correctTargetIndexes: [0, 1],
        successMessage: 'جميل! عرفت العائلة.',
      ),
    ],
    [
      AssessmentActivityEntity(
        prompt: 'من أنت؟',
        type: AssessmentGameType.cameraIdentity,
        emoji: '🪞',
        options: [],
        successMessage: '',
      ),
      AssessmentActivityEntity(
        prompt: 'ما هو إسمك؟',
        type: AssessmentGameType.nameAndGender,
        emoji: '🎤',
        options: ['ولد', 'بنت'],
        imagePaths: [
          'assets/image/boy.jpg',
          'assets/image/girl.jpg', // Please add a girl.jpg to assets
        ],
        successMessage: 'أحسنت!',
      ),
    ],
    [
      AssessmentActivityEntity(
        prompt: 'ركّب أجزاء البازل',
        type: AssessmentGameType.puzzle,
        emoji: '🧩',
        options: [
          'نصف طائرة يمين',
          'نصف طائرة يسار',
          'نصف سيارة يمين',
          'نصف سيارة يسار',
        ],
        imagePaths: [
          'assets/image/plane_right.jpg',
          'assets/image/plane_left.jpg',
          'assets/image/car_right.jpg',
          'assets/image/car_left.jpg',
        ],
        targets: ['طائرة', 'سيارة'],
        correctTargetIndexes: [
          0,
          0,
          1,
          1,
        ], // The first two options go to the first target, etc.
        successMessage: 'عمل رائع! ركبت البازل.',
      ),
      AssessmentActivityEntity(
        prompt: 'وصل الوسيلة بقائدها',
        type: AssessmentGameType.dragToTarget,
        emoji: '✈️',
        iconPath: 'assets/image/Theplane.jpg',
        options: ['الطيار', 'السائق', 'الصياد'],
        imagePaths: [
          'assets/image/pilot.jpg',
          'assets/image/driver.jpg',
          'assets/image/captain.jpg',
        ],
        targets: ['طائرة', 'سيارة', 'مركب'],
        targetImagePaths: [
          'assets/image/Theplane.jpg',
          'assets/image/car.jpg',
          'assets/image/Theship.jpg',
        ],
        correctTargetIndexes: [0, 1, 2],
        successMessage: 'برافو! عرفت القائد المناسب.',
      ),
    ],
    [
      AssessmentActivityEntity(
        prompt: 'ركّب أجزاء البازل',
        type: AssessmentGameType.puzzle,
        emoji: '🧩',
        options: [
          'نصف مركب يمين',
          'نصف مركب يسار',
          'نصف إسعاف يمين',
          'نصف إسعاف يسار',
        ],
        imagePaths: [
          'assets/image/ship_right.jpg',
          'assets/image/ship_left.jpg',
          'assets/image/ambulance_right.jpg',
          'assets/image/ambulance_left.jpg',
        ],
        targets: ['مركب', 'إسعاف'],
        correctTargetIndexes: [0, 0, 1, 1],
        successMessage: 'أحسنت في تركيب البازل!',
      ),
      AssessmentActivityEntity(
        prompt: 'وصل الوسيلة بوظيفتها',
        type: AssessmentGameType.dragToTarget,
        emoji: '🚑',
        options: ['الإسعاف', 'المطافي'],
        imagePaths: [
          'assets/image/Ambulance.jpg',
          'assets/image/fireـdepartment.jpg',
        ],
        targets: ['تساعد المريض', 'تطفي الحريق'],
        targetImagePaths: [
          'assets/image/thepatient.jpg',
          'assets/image/fire.jpg',
        ],
        correctTargetIndexes: [0, 1],
        successMessage: 'صحيح! عرفت وظيفة الوسيلة.',
      ),
    ],
    [
      AssessmentActivityEntity(
        prompt: 'اختار الألوان الأساسية الثلاثة',
        type: AssessmentGameType.selectMany,
        emoji: '🎨',
        options: ['أحمر', 'أصفر', 'أزرق', 'برتقالي'],
        correctOptionIndexes: [0, 1, 2],
        colorValues: [0xffF44336, 0xffFFCA28, 0xff2196F3, 0xffFB8C00],
        successMessage: 'ممتاز! عرفت الألوان الأساسية.',
      ),
      AssessmentActivityEntity(
        prompt: 'الأحمر + الأزرق = ؟',
        type: AssessmentGameType.colorMix,
        emoji: '🟣',
        options: ['بنفسجي', 'أحمر'],
        correctOptionIndex: 0,
        colorValues: [0xffF44336, 0xff2196F3, 0xff8E24AA, 0xffF44336],
        successMessage: 'صح! الأحمر والأزرق يصنعان البنفسجي.',
      ),
    ],
    [
      AssessmentActivityEntity(
        prompt: 'اختار فرشاة ولوّن الدوائر الثلاث',
        type: AssessmentGameType.coloring,
        emoji: '🖌️',
        options: ['برتقالي', 'أخضر', 'بنفسجي', 'أزرق'],
        targets: ['دائرة ١', 'دائرة ٢', 'دائرة ٣'],
        colorValues: [0xffFB8C00, 0xff43A047, 0xff8E24AA, 0xff2196F3],
        successMessage: 'لوحة جميلة يا فنان!',
      ),
      AssessmentActivityEntity(
        prompt: 'الأزرق + الأصفر = ؟',
        type: AssessmentGameType.colorMix,
        emoji: '🟢',
        options: ['أخضر', 'برتقالي'],
        correctOptionIndex: 0,
        colorValues: [0xff2196F3, 0xffFFCA28, 0xff43A047, 0xffFB8C00],
        successMessage: 'رائع! الأزرق والأصفر يصنعان الأخضر.',
      ),
    ],
    [
      AssessmentActivityEntity(
        prompt: 'اضغط على الفاكهة لتسمع اسمها، ثم انطقها',
        type: AssessmentGameType.speechPicture,
        emoji: '🎙️',
        options: ['تفاحة', 'بطيخة'],
        audioPaths: [
          'assets/audio/fruit_apple.m4a',
          'assets/audio/fruit_watermelon.m4a',
        ],
        imagePaths: [
          'assets/image/colored_apple.jpg',
          'assets/image/colored_watermelon.jpg',
        ],
        successMessage: 'نطق رائع! عرفت التفاحة والبطيخة.',
      ),
      AssessmentActivityEntity(
        prompt: 'اختار الألوان ولوّن الفواكه',
        type: AssessmentGameType.coloring,
        emoji: '🖌️',
        options: ['برتقالي', 'أخضر', 'أحمر', 'وردي'],
        targets: ['برتقالة', 'بطيخة', 'فراولة'],
        targetImagePaths: [
          'assets/image/uncolored_orange.jpg',
          'assets/image/uncolored_watermelon.jpg',
          'assets/image/uncolored_strawberry.jpg',
        ],
        colorValues: [0xffFB8C00, 0xff43A047, 0xffF44336, 0xffEC407A],
        successMessage: 'ألوان الفواكه مبهجة!',
      ),
    ],
    [
      AssessmentActivityEntity(
        prompt: 'اسمع اسم الفاكهة ثم انطقها',
        type: AssessmentGameType.speechPicture,
        emoji: '🎙️',
        options: ['موزة', 'عنب', 'مانجا'],
        audioPaths: [
          'assets/audio/fruit_banana.m4a',
          'assets/audio/fruit_grapes.m4a',
          'assets/audio/fruit_mango.m4a',
        ],
        successMessage: 'ممتاز! نطقت أسماء الفواكه.',
      ),
      AssessmentActivityEntity(
        prompt: 'فرقّع البالونة التي عليها أول حرف من كلمة موزة',
        type: AssessmentGameType.balloonPop,
        emoji: '🎈',
        options: ['م', 'ب', 'ت', 'ف'],
        correctOptionIndex: 0,
        colorValues: [0xffEF5350, 0xff42A5F5, 0xffAB47BC, 0xff66BB6A],
        successMessage: 'بوب! حرف الميم هو الاختيار الصحيح.',
      ),
    ],
    [
      AssessmentActivityEntity(
        prompt: 'اسحب مكونات السلطة إلى الطبق، وضع الفاكهة بعيداً',
        type: AssessmentGameType.conveyorSort,
        emoji: '🥗',
        options: ['طماطم', 'خيار', 'بصل', 'خس', 'موزة', 'تفاحة', 'برتقالة'],
        targets: ['طبق السلطة', 'طبق الفاكهة'],
        targetImagePaths: [
          'assets/image/salad_bowl.png',
          'assets/image/fruit_bowl.png',
        ],
        correctTargetIndexes: [0, 0, 0, 0, 1, 1, 1],
        successMessage: 'حضّرت طبق سلطة صحي ولذيذ!',
      ),
      AssessmentActivityEntity(
        prompt: 'لوّن الطماطم والخيار بالفرشاة',
        type: AssessmentGameType.coloring,
        emoji: '🖌️',
        options: ['أحمر', 'أخضر', 'أصفر', 'بنفسجي'],
        targets: ['طماطم', 'خيار'],
        targetImagePaths: [
          'assets/image/uncolored_tomato.jpg',
          'assets/image/uncolored_cucumber.jpg',
        ],
        colorValues: [0xffF44336, 0xff43A047, 0xffFFCA28, 0xff8E24AA],
        successMessage: 'تلوين جميل للخضروات!',
      ),
    ],
    [
      AssessmentActivityEntity(
        prompt: 'صنّف ما يمر على السير: للسلطة أم لا؟',
        type: AssessmentGameType.conveyorSort,
        emoji: '🧳',
        options: [
          'خس',
          'خيار',
          'بصل',
          'طماطم',
          'ليمون',
          'فلفل',
          'جزر',
          'بنجر',
          'بطيخة',
          'عنب',
          'مانجا',
          'فراولة',
          'جوافة',
        ],
        imagePaths: [
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          'assets/image/beetroot.jpeg',
          '',
          '',
          '',
          '',
          '',
        ],
        targets: ['طبق السلطة', 'طبق الفاكهة'],
        targetImagePaths: [
          'assets/image/salad_bowl.png',
          'assets/image/fruit_bowl.png',
        ],
        correctTargetIndexes: [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
        successMessage: 'تصنيف ممتاز! عرفت مكونات السلطة.',
      ),
      AssessmentActivityEntity(
        prompt: 'لوّن الفلفل والليمون',
        type: AssessmentGameType.coloring,
        emoji: '🖌️',
        options: ['أخضر', 'أصفر', 'أحمر', 'بنفسجي'],
        targets: ['فلفل', 'ليمون'],
        targetImagePaths: [
          'assets/image/uncolored_pepper.jpg',
          'assets/image/uncolored_lemon.jpg',
        ],
        colorValues: [0xff43A047, 0xffFFCA28, 0xffF44336, 0xff8E24AA],
        successMessage: 'أحسنت التلوين!',
      ),
    ],
    [
      AssessmentActivityEntity(
        prompt: 'شاهد الكروت جيدًا، وبعد أن تختفي اختر الحواس الخمس',
        type: AssessmentGameType.memoryReveal,
        emoji: '🧠',
        options: [
          'اليد',
          'الأذن',
          'العين',
          'اللسان',
          'الأنف',
          'القطة',
          'البقرة',
        ],
        imagePaths: [
          'assets/image/hand_sense.png',
          'assets/image/ear_sense.png',
          'assets/image/eye_sense.png',
          'assets/image/tongue_sense.png',
          'assets/image/nose_sense.png',
          'assets/image/cat_3d.png',
          'assets/image/cow_3d.png',
        ],
        correctOptionIndexes: [0, 1, 2, 3, 4],
        successMessage: 'ذاكرة رائعة! تذكرت الحواس الخمس.',
      ),
      AssessmentActivityEntity(
        prompt: 'ردد كلمات الاغنيه معايا',
        type: AssessmentGameType.songRepeat,
        emoji: '🎵',
        options: [],
        videoUrl: 'assets/vedios/VIDEO-2026-08-26-17-08-14.mp4',
        successMessage: 'أحسنت الترديد يا بطل الحواس!',
      ),
    ],
    [
      AssessmentActivityEntity(
        prompt: 'فرقّع بالونات الأشكال الهندسية الأربعة',
        type: AssessmentGameType.shapeBalloons,
        emoji: '🎈',
        options: ['مربع', 'مثلث', 'مستطيل', 'دائرة'],
        colorValues: [0xffEF5350, 0xff42A5F5, 0xffAB47BC, 0xff66BB6A],
        videoPaths: [
          'assets/vedios/shape_balloon_square.mp4',
          'assets/vedios/shape_balloon_triangle.mp4',
          'assets/vedios/shape_balloon_rectangle.mp4',
          'assets/vedios/shape_balloon_circle.mp4',
        ],
        successMessage: 'رائع! عرفت الأشكال الهندسية.',
      ),
      AssessmentActivityEntity(
        prompt: 'امسك القلم ومرّره على النقاط لرسم المربع',
        type: AssessmentGameType.traceShape,
        emoji: '✏️',
        options: ['مربع'],
        successMessage: 'رسمت مربعًا جميلًا!',
      ),
    ],
    [
      AssessmentActivityEntity(
        prompt: 'اسمع الكلمة ثم صِلها بالصورة الصحيحة',
        type: AssessmentGameType.dragToTarget,
        emoji: '👁️',
        options: ['أنف', 'عين'],
        // Use bundled recordings here instead of device TTS. Some Android
        // devices do not have an Arabic TTS voice installed, which made these
        // two speaker buttons appear to do nothing.
        audioPaths: [
          'assets/audio/body_part_nose.m4a',
          'assets/audio/body_part_eye.m4a',
        ],
        audioOnlyOptions: true,
        targets: ['صورة الأنف', 'صورة العين'],
        targetImagePaths: [
          'assets/image/nose_sense.png',
          'assets/image/eye_sense.png',
        ],
        correctTargetIndexes: [0, 1],
        successMessage: 'أحسنت! وصلت الصوت بالصورة الصحيحة.',
      ),
      AssessmentActivityEntity(
        prompt: 'اسحب كل جزء إلى مكانه في الجسم',
        type: AssessmentGameType.bodyPartsBuilder,
        emoji: '🧍‍♂️',
        iconPath: 'assets/image/body_parts_board_empty.jpeg',
        options: [
          'العين',
          'الأنف',
          'الفم',
          'السروال',
          'الركبة',
          'الرأس',
          'الأذن',
          'اليد',
          'الذراع',
          'القدم',
        ],
        imagePaths: [
          'assets/image/body_part_eye.jpeg',
          'assets/image/body_part_nose.jpeg',
          'assets/image/body_part_mouth.jpeg',
          'assets/image/body_part_shorts.jpeg',
          'assets/image/body_part_knee.jpeg',
          'assets/image/body_part_head.jpeg',
          'assets/image/body_part_ear.jpeg',
          'assets/image/body_part_hand.jpeg',
          'assets/image/body_part_arm.jpeg',
          'assets/image/body_part_foot.jpeg',
        ],
        targets: [
          'العين',
          'الأنف',
          'الفم',
          'السروال',
          'الركبة',
          'الرأس',
          'الأذن',
          'اليد',
          'الذراع',
          'القدم',
        ],
        mergedTargetImagePaths: ['assets/image/body_parts_board_complete.jpeg'],
        correctTargetIndexes: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        successMessage: 'عمل رائع! أكملت أجزاء الجسم.',
      ),
    ],
    [
      AssessmentActivityEntity(
        prompt: 'اسحب علامة ✓ أو ✖ إلى الدوائر المناسبة',
        type: AssessmentGameType.bodyPrivacyMarkers,
        emoji: '🛡️',
        iconPath: 'assets/image/privacy_body_board_empty.jpeg',
        options: ['خطأ', 'صح'],
        imagePaths: [
          'assets/image/privacy_marker_wrong.jpeg',
          'assets/image/privacy_marker_correct.jpeg',
        ],
        targets: [
          'وجه الولد',
          'رأس البنت',
          'يد البنت',
          'فم البنت',
          'صدر البنت',
          'المنطقة الخاصة للبنت',
          'المنطقة الخاصة للولد',
        ],
        correctTargetIndexes: [1, 1, 1, 0, 0, 0, 0],
        mergedTargetImagePaths: [
          'assets/image/privacy_body_board_complete.jpeg',
        ],
        successMessage: 'ممتاز! أنت تعرف خصوصية جسمك.',
      ),
      AssessmentActivityEntity(
        prompt: 'رتّب خطوات حماية جسمنا في عربات القطار',
        type: AssessmentGameType.sequenceTrain,
        emoji: '🚂',
        options: [
          'أقول لا وأُبعد اليد',
          'أصرخ وأطلب المساعدة',
          'أذهب لشخص بالغ موثوق وأحكي',
          'الشرطة تحمي الطفل وتوقف المعتدي',
        ],
        imagePaths: [
          'assets/image/He_ran_away_from_him.jpg',
          'assets/image/Shout_and_ask_for_help.jpg',
          'assets/image/Ill_go_to_someone_and_tell_him.jpg',
          'assets/image/police_officer.jpg',
        ],
        successMessage: 'ترتيب صحيح! لا، ابتعد، أخبر شخصًا موثوقًا.',
      ),
    ],
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // 2. Full template pool — one entry per potential level.
  //    Only the first videoPaths.length entries will be used.
  // ─────────────────────────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> _levelTemplates = [
    // 1. الحيوانات
    {
      'title': 'أسرتي',
      'emoji': '🐾',
      'colorCode': '#4CAF50',
      'bgColorCode': '#E8F5E9',
      'exercises': [
        ExerciseEntity(
          id: '1-1',
          type: ExerciseType.listenRepeat,
          prompt: 'قول: قطة 🐱',
          word: 'قطة',
          image: '🐱',
          hint: 'الحيوان اللي بيموء وبحب اللبن',
        ),
        ExerciseEntity(
          id: '1-2',
          type: ExerciseType.describeImage,
          prompt: 'صف اللي شايفه في الصورة 🌳',
          image: '🌳',
          expectedWords: ['شجرة', 'خضراء', 'كبيرة'],
        ),
        ExerciseEntity(
          id: '1-3',
          type: ExerciseType.answerQuestion,
          prompt: 'إيه صوت الكلب؟ 🐶',
          image: '🐶',
          expectedAnswer: 'هو هو',
          hint: 'الكلب بيقول هو هو',
        ),
      ],
    },
    // 2. الفواكه
    {
      'title': 'حيوانات مزرعة الفلاح',
      'emoji': '🍎',
      'colorCode': '#FF9800',
      'bgColorCode': '#FFF3E0',
      'exercises': [
        ExerciseEntity(
          id: '2-1',
          type: ExerciseType.listenRepeat,
          prompt: 'قول: تفاحة 🍎',
          word: 'تفاحة',
          image: '🍎',
          hint: 'فاكهة حمراء ولذيذة ومفيدة',
        ),
        ExerciseEntity(
          id: '2-2',
          type: ExerciseType.describeImage,
          prompt: 'صف الموزة الجميلة 🍌',
          image: '🍌',
          expectedWords: ['موز', 'أصفر', 'حلو'],
        ),
        ExerciseEntity(
          id: '2-3',
          type: ExerciseType.answerQuestion,
          prompt: 'إيه الفاكهة اللي لونها برتقالي؟ 🍊',
          image: '🍊',
          expectedAnswer: 'برتقال',
          hint: 'بنعمل منها عصير برتقال مفيد',
        ),
      ],
    },
    // 3. الألوان
    {
      'title': 'حيوانات مزرعة الفلاح ',
      'emoji': '🎨',
      'colorCode': '#9C27B0',
      'bgColorCode': '#F3E5F5',
      'exercises': [
        ExerciseEntity(
          id: '3-1',
          type: ExerciseType.listenRepeat,
          prompt: 'قول: أحمر 🔴',
          word: 'أحمر',
          image: '🔴',
          hint: 'مثل لون الطماطم والتفاح',
        ),
        ExerciseEntity(
          id: '3-2',
          type: ExerciseType.describeImage,
          prompt: 'صف لون البحر والسماء 🌊',
          image: '🌊',
          expectedWords: ['بحر', 'أزرق', 'جميل'],
        ),
        ExerciseEntity(
          id: '3-3',
          type: ExerciseType.answerQuestion,
          prompt: 'الورقة دي لونها إيه؟ 🌿',
          image: '🌿',
          expectedAnswer: 'أخضر',
          hint: 'لون الشجر والزرع',
        ),
      ],
    },
    // 4. الأرقام
    {
      'title': 'من أنا؟',
      'emoji': '🔢',
      'colorCode': '#2196F3',
      'bgColorCode': '#E3F2FD',
      'exercises': [
        ExerciseEntity(
          id: '4-1',
          type: ExerciseType.listenRepeat,
          prompt: 'قول: واحد ☝️',
          word: 'واحد',
          image: '☝️',
          hint: 'أول رقم بنعده',
        ),
        ExerciseEntity(
          id: '4-2',
          type: ExerciseType.describeImage,
          prompt: 'عد التفاحات في الصورة 🍎🍎',
          image: '🍎🍎',
          expectedWords: ['اثنين', 'تفاحتان', 'تفاح'],
        ),
        ExerciseEntity(
          id: '4-3',
          type: ExerciseType.answerQuestion,
          prompt: 'كم إصبعاً مرفوعاً في اليد؟ 🖐️',
          image: '🖐️',
          expectedAnswer: 'خمسة',
          hint: 'عد صوابع إيدك',
        ),
      ],
    },
    // 5. الجسم
    {
      'title': 'وسائل المواصلات',
      'emoji': '👀',
      'colorCode': '#F44336',
      'bgColorCode': '#FFEBEE',
      'exercises': [
        ExerciseEntity(
          id: '5-1',
          type: ExerciseType.listenRepeat,
          prompt: 'قول: عين 👀',
          word: 'عين',
          image: '👀',
          hint: 'العضو اللي بنشوف بيه الدنيا',
        ),
        ExerciseEntity(
          id: '5-2',
          type: ExerciseType.describeImage,
          prompt: 'صف شكل اليد المفتوحة 🖐️',
          image: '🖐️',
          expectedWords: ['يد', 'أصابع', 'خمسة'],
        ),
        ExerciseEntity(
          id: '5-3',
          type: ExerciseType.answerQuestion,
          prompt: 'بنسمع إيه بصوت العصافير؟ 👂',
          image: '👂',
          expectedAnswer: 'أذن',
          hint: 'العضو اللي على جانب راسنا وبنسمع بيه',
        ),
      ],
    },
    // 6. المواصلات
    {
      'title': 'وسائل المواصلات',
      'emoji': '🚗',
      'colorCode': '#009688',
      'bgColorCode': '#E0F2F1',
      'exercises': [
        ExerciseEntity(
          id: '6-1',
          type: ExerciseType.listenRepeat,
          prompt: 'قول: سيارة 🚗',
          word: 'سيارة',
          image: '🚗',
          hint: 'بنركبها عشان نروح مشاوير ولها 4 عجلات',
        ),
        ExerciseEntity(
          id: '6-2',
          type: ExerciseType.describeImage,
          prompt: 'صف الطائرة في السماء ✈️',
          image: '✈️',
          expectedWords: ['طائرة', 'تطير', 'سماء'],
        ),
        ExerciseEntity(
          id: '6-3',
          type: ExerciseType.answerQuestion,
          prompt: 'إيه اللي بيمشي على القضبان وبيقول توت توت؟ 🚂',
          image: '🚂',
          expectedAnswer: 'قطار',
          hint: 'مركبة طويلة جداً وبتشيل ناس كتير',
        ),
      ],
    },
    // 7. وردة الألوان
    {
      'title': 'وردة الألوان',
      'emoji': '🌸',
      'colorCode': '#03A9F4',
      'bgColorCode': '#E1F5FE',
      'exercises': [
        ExerciseEntity(
          id: '7-1',
          type: ExerciseType.listenRepeat,
          prompt: 'قول: شمس ☀️',
          word: 'شمس',
          image: '☀️',
          hint: 'بتدينا النور والدفا الصبح',
        ),
        ExerciseEntity(
          id: '7-2',
          type: ExerciseType.describeImage,
          prompt: 'صف المطر المتساقط 🌧️',
          image: '🌧️',
          expectedWords: ['مطر', 'سحاب', 'ماء'],
        ),
        ExerciseEntity(
          id: '7-3',
          type: ExerciseType.answerQuestion,
          prompt: 'إيه اللي بيطلع في السما بالليل وينور؟ 🌙',
          image: '🌙',
          expectedAnswer: 'قمر',
          hint: 'بيكون هلال أو بدر ومنير بالليل',
        ),
      ],
    },
    // 8. وردة الألوان ٢
    {
      'title': 'وردة الألوان ٢',
      'emoji': '🌈',
      'colorCode': '#E91E8C',
      'bgColorCode': '#FCE4EC',
      'exercises': [
        ExerciseEntity(
          id: '8-1',
          type: ExerciseType.listenRepeat,
          prompt: 'قول: قميص 👕',
          word: 'قميص',
          image: '👕',
          hint: 'لبس بنلبسه فوق وله أكمام وزراير',
        ),
        ExerciseEntity(
          id: '8-2',
          type: ExerciseType.describeImage,
          prompt: 'صف هذا الفستان الجميل 👗',
          image: '👗',
          expectedWords: ['فستان', 'بنت', 'جميل'],
        ),
        ExerciseEntity(
          id: '8-3',
          type: ExerciseType.answerQuestion,
          prompt: 'بنلبس إيه في رجلينا عشان نمشي؟ 👟',
          image: '👟',
          expectedAnswer: 'حذاء',
          hint: 'كوتشي أو جزمة لحماية القدم',
        ),
      ],
    },
    // 9. الفواكه
    {
      'title': 'الفواكه',
      'emoji': '🍎',
      'colorCode': '#FF5722',
      'bgColorCode': '#FBE9E7',
      'exercises': [
        ExerciseEntity(
          id: '9-1',
          type: ExerciseType.listenRepeat,
          prompt: 'قول: خبز 🍞',
          word: 'خبز',
          image: '🍞',
          hint: 'بنعمل منه السندوتشات كل يوم',
        ),
        ExerciseEntity(
          id: '9-2',
          type: ExerciseType.describeImage,
          prompt: 'صف البيتزا اللذيذة 🍕',
          image: '🍕',
          expectedWords: ['بيتزا', 'لذيذة', 'جبنة'],
        ),
        ExerciseEntity(
          id: '9-3',
          type: ExerciseType.answerQuestion,
          prompt: 'حاجة لونها أبيض بنشربها مفيدة للعظام؟ 🥛',
          image: '🥛',
          expectedAnswer: 'حليب',
          hint: 'اللبن المفيد المغذي اللي البقرة بتجيبه',
        ),
      ],
    },
    // 10. باقي الفواكه
    {
      'title': 'باقي الفواكه',
      'emoji': '🍇',
      'colorCode': '#FFC107',
      'bgColorCode': '#FFFDE7',
      'exercises': [
        ExerciseEntity(
          id: '10-1',
          type: ExerciseType.listenRepeat,
          prompt: 'قول: سعيد 😊',
          word: 'سعيد',
          image: '😊',
          hint: 'لما تكون مبسوط وبتضحك',
        ),
        ExerciseEntity(
          id: '10-2',
          type: ExerciseType.describeImage,
          prompt: 'صف وجه هذا الطفل 😢',
          image: '😢',
          expectedWords: ['حزين', 'يبكي', 'دموع'],
        ),
        ExerciseEntity(
          id: '10-3',
          type: ExerciseType.answerQuestion,
          prompt: 'الولد اللي عيونه حمراء ده حاسس بإيه؟ 😡',
          image: '😡',
          expectedAnswer: 'غاضب',
          hint: 'زعلان جداً ومتعصب',
        ),
      ],
    },
    // 11. طبق سلطة
    {
      'title': 'طبق سلطة',
      'emoji': '🥗',
      'colorCode': '#795548',
      'bgColorCode': '#EFEBE9',
      'exercises': [
        ExerciseEntity(
          id: '11-1',
          type: ExerciseType.listenRepeat,
          prompt: 'قول: بيت 🏠',
          word: 'بيت',
          image: '🏠',
          hint: 'المكان اللي بنعيش فيه مع أسرتنا',
        ),
        ExerciseEntity(
          id: '11-2',
          type: ExerciseType.describeImage,
          prompt: 'صف السرير المريح 🛏️',
          image: '🛏️',
          expectedWords: ['سرير', 'نوم', 'مريح'],
        ),
        ExerciseEntity(
          id: '11-3',
          type: ExerciseType.answerQuestion,
          prompt: 'بنفتح إيه عشان ندخل الأوضة؟ 🚪',
          image: '🚪',
          expectedAnswer: 'باب',
          hint: 'له مقبض وبنفتحه ونقفله',
        ),
      ],
    },
    // 12. باقي طبق السلطة
    {
      'title': 'باقي طبق السلطة',
      'emoji': '🥒',
      'colorCode': '#3F51B5',
      'bgColorCode': '#E8EAF6',
      'exercises': [
        ExerciseEntity(
          id: '12-1',
          type: ExerciseType.listenRepeat,
          prompt: 'قول: كتاب 📖',
          word: 'كتاب',
          image: '📖',
          hint: 'بنفتحه ونقرا منه قصص ومعلومات',
        ),
        ExerciseEntity(
          id: '12-2',
          type: ExerciseType.describeImage,
          prompt: 'صف القلم الملون ✏️',
          image: '✏️',
          expectedWords: ['قلم', 'كتابة', 'أصفر'],
        ),
        ExerciseEntity(
          id: '12-3',
          type: ExerciseType.answerQuestion,
          prompt: 'بنحط الكتب والأقلام في إيه وإحنا رايحين المدرسة؟ 🎒',
          image: '🎒',
          expectedAnswer: 'حقيبة',
          hint: 'شنطة بنشيلها على ضهرنا',
        ),
      ],
    },
    // 13. الحواس الخمس
    {
      'title': 'الحواس الخمس',
      'emoji': '👁️',
      'colorCode': '#8BC34A',
      'bgColorCode': '#F1F8E9',
      'exercises': [
        ExerciseEntity(
          id: '13-1',
          type: ExerciseType.listenRepeat,
          prompt: 'قول: وردة 🌹',
          word: 'وردة',
          image: '🌹',
          hint: 'زهرة حمراء ريحتها حلوة وشكلها جميل',
        ),
        ExerciseEntity(
          id: '13-2',
          type: ExerciseType.describeImage,
          prompt: 'صف الجبل العالي 🏔️',
          image: '🏔️',
          expectedWords: ['جبل', 'كبير', 'مرتفع'],
        ),
        ExerciseEntity(
          id: '13-3',
          type: ExerciseType.answerQuestion,
          prompt: 'النباتات بتكبر فين وتحت رجلنا؟ 🌿',
          image: '🌿',
          expectedAnswer: 'عشب',
          hint: 'النجيل الأخضر اللي في الحديقة',
        ),
      ],
    },
    // 14. الأشكال الهندسية
    {
      'title': 'الأشكال الهندسية',
      'emoji': '⭐',
      'colorCode': '#FF4081',
      'bgColorCode': '#FCE4EC',
      'exercises': [
        ExerciseEntity(
          id: '14-1',
          type: ExerciseType.listenRepeat,
          prompt: 'قول: دائرة 🔴',
          word: 'دائرة',
          image: '🔴',
          hint: 'شكل مدور زي الكورة والساعة',
        ),
        ExerciseEntity(
          id: '14-2',
          type: ExerciseType.describeImage,
          prompt: 'صف هذا المربع 🟩',
          image: '🟩',
          expectedWords: ['مربع', 'أخضر', 'أربعة أضلاع'],
        ),
        ExerciseEntity(
          id: '14-3',
          type: ExerciseType.answerQuestion,
          prompt: 'الشكل ده اسمه إيه؟ 🔺',
          image: '🔺',
          expectedAnswer: 'مثلث',
          hint: 'شكل له 3 أضلاع و 3 زوايا',
        ),
      ],
    },
    // 15. أجزاء الوجه
    {
      'title': 'أجزاء جسمي',
      'emoji': '🙂',
      'colorCode': '#607D8B',
      'bgColorCode': '#ECEFF1',
      'exercises': [
        ExerciseEntity(
          id: '15-1',
          type: ExerciseType.listenRepeat,
          prompt: 'قول: عائلة 👨‍👩‍👧‍👦',
          word: 'عائلة',
          image: '👨‍👩‍👧‍👦',
          hint: 'أبي وأمي وإخوتي اللي بنحبهم',
        ),
        ExerciseEntity(
          id: '15-2',
          type: ExerciseType.describeImage,
          prompt: 'صف هذا الرجل الطيب 👨',
          image: '👨',
          expectedWords: ['أب', 'رجل', 'جميل'],
        ),
        ExerciseEntity(
          id: '15-3',
          type: ExerciseType.answerQuestion,
          prompt: 'من التي ترضع الطفل وتحبه؟ 👩‍🍼',
          image: '👩‍🍼',
          expectedAnswer: 'أم',
          hint: 'ماما الطيبة اللي بترعانا',
        ),
      ],
    },
    // 16. حماية جسمي
    {
      'title': 'حماية جسمي',
      'emoji': '🛡️',
      'colorCode': '#FF6F00',
      'bgColorCode': '#FFF3E0',
      'exercises': [
        ExerciseEntity(
          id: '16-1',
          type: ExerciseType.listenRepeat,
          prompt: 'قول: طبيب 👨‍⚕️',
          word: 'طبيب',
          image: '👨‍⚕️',
          hint: 'الشخص اللي بيكشف علينا ويدينا الدوا لما نتعب',
        ),
        ExerciseEntity(
          id: '16-2',
          type: ExerciseType.describeImage,
          prompt: 'صف هذا المعلم النشيط 👨‍🏫',
          image: '👨‍🏫',
          expectedWords: ['معلم', 'مدرسة', 'سبورة'],
        ),
        ExerciseEntity(
          id: '16-3',
          type: ExerciseType.answerQuestion,
          prompt: 'من الذي يطفي الحريق ويرتدي بدلة حمراء؟ 👨‍🚒',
          image: '👨‍🚒',
          expectedAnswer: 'إطفائي',
          hint: 'رجل الإطفاء الشجاع',
        ),
      ],
    },
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // 3. Exposed list: one LevelEntity per video in [videoPaths].
  //    Automatically trims or expands as videos are added / removed.
  // ─────────────────────────────────────────────────────────────────────────
  static final List<LevelEntity> levels = List.generate(videoPaths.length, (i) {
    final template = _levelTemplates[i];
    return LevelEntity(
      id: i + 1,
      title: template['title'] as String,
      emoji: template['emoji'] as String,
      colorCode: template['colorCode'] as String,
      bgColorCode: template['bgColorCode'] as String,
      exercises: template['exercises'] as List<ExerciseEntity>,
      assessmentActivities: assessmentActivities[i],
      videoPath: videoPaths[i],
    );
  });
}
