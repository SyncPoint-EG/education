import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/services/audio_output_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/speech_service.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/profile/presentation/pages/splash_page.dart';
import 'features/map/presentation/cubit/map_cubit.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  await AudioOutputService.configureForPlayback();

  // Instantiate core infrastructure services
  final StorageService storageService = StorageServiceImpl();
  await storageService.init();

  final SpeechService speechService = SpeechServiceImpl();
  await speechService.init();

  runApp(MyApp(storageService: storageService, speechService: speechService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  final SpeechService speechService;

  const MyApp({
    super.key,
    required this.storageService,
    required this.speechService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<StorageService>.value(value: storageService),
        RepositoryProvider<SpeechService>.value(value: speechService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ProfileCubit>(
            create: (context) => ProfileCubit(storageService),
          ),
          BlocProvider<MapCubit>(create: (context) => MapCubit()),
        ],
        child: MaterialApp(
          title: 'استمع وتحدث',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const SplashPage(),
        ),
      ),
    );
  }
}
