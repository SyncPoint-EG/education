import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum CurrencyType { gold, gem }

class CurrencyChip extends StatelessWidget {
  final int value;
  final CurrencyType type;

  const CurrencyChip({
    super.key,
    required this.value,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGold = type == CurrencyType.gold;
    final String icon = isGold ? '🪙' : '💎';
    final Gradient bgGrad = isGold ? AppColors.goldGradient : AppColors.gemGradient;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: bgGrad,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
