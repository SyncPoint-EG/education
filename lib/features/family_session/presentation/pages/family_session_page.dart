import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import 'feelings_page.dart';

/// Orchestrates the 1 activity of the Family Session:
///  1) Feelings Assessment
class FamilySessionPage extends StatefulWidget {
  final int initialStars;
  const FamilySessionPage({super.key, this.initialStars = 0});

  @override
  State<FamilySessionPage> createState() => _FamilySessionPageState();
}

class _FamilySessionPageState extends State<FamilySessionPage> {
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
        context.read<ProfileCubit>().completeLevel(1, _totalStars);
        Navigator.pop(context);
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
                sessionName: 'جلسة أسرتي',
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
