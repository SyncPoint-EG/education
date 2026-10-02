import 'package:education/features/family_session/presentation/pages/feelings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';

/// Orchestrates the activities of the Farm Session:
/// 1) Feelings Assessment
class FarmSessionPage extends StatefulWidget {
  final int initialStars;
  const FarmSessionPage({super.key, this.initialStars = 0});

  @override
  State<FarmSessionPage> createState() => _FarmSessionPageState();
}

class _FarmSessionPageState extends State<FarmSessionPage> {
  int _currentActivity = 0; // 0 = feelings
  late int _totalStars;

  @override
  void initState() {
    super.initState();
    _totalStars = widget.initialStars;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onActivityComplete(int starsEarned) {
    setState(() {
      _totalStars += starsEarned;
      _currentActivity++;

      if (_currentActivity > 0) {
        context.read<ProfileCubit>().completeLevel(2, _totalStars);
        Navigator.pop(context, _totalStars);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppColors.bgGradient),
          child: SafeArea(
            child: switch (_currentActivity) {
              0 => FeelingsPage(
                totalStars: _totalStars + 1,
                sessionName: 'جلسة المزرعة',
                onComplete: () => _onActivityComplete(1),
              ),
              _ => const SizedBox.shrink(),
            },
          ),
        ),
      ),
    );
  }
}
