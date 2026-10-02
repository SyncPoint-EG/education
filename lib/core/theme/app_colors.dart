import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xff4ADE80);
  static const Color primaryDark = Color(0xff22C55E);
  static const Color primaryShadow = Color(0xff16A34A);

  static const Color secondary = Color(0xffFBBF24);
  static const Color secondaryDark = Color(0xffF59E0B);
  static const Color secondaryShadow = Color(0xffD97706);

  static const Color accent = Color(0xffF472B6);
  static const Color accentShadow = Color(0xffDB2777);

  static const Color blue = Color(0xff60A5FA);
  static const Color blueDark = Color(0xff3B82F6);
  static const Color blueShadow = Color(0xff2563EB);

  static const Color red = Color(0xffF87171);
  static const Color redDark = Color(0xffEF4444);
  static const Color redShadow = Color(0xffDC2626);

  static const Color purple = Color(0xffC084FC);
  static const Color yellow = Color(0xffFDE047);
  static const Color gray = Color(0xff9CA3AF);
  static const Color grayDark = Color(0xff4B5563);

  static const Color bgMain = Color(0xffFDF8F5);
  static const Color bgCard = Color(0xffFFFFFF);

  static const Color textDark = Color(0xff1E293B);
  static const Color textMid = Color(0xff64748B);
  static const Color textLight = Color(0xff94A3B8);

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient blueGradient = LinearGradient(
    colors: [blue, blueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient redGradient = LinearGradient(
    colors: [red, redDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient grayGradient = LinearGradient(
    colors: [gray, grayDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient bgGradient = LinearGradient(
    colors: [Color(0xffFFF1E6), Color(0xffFDF8F5), Color(0xffF3E8FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient mapBgGradient = LinearGradient(
    colors: [Color(0xffFEF3C7), Color(0xffFDE68A), Color(0xffFCD34D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient goldGradient = LinearGradient(
    colors: [Color(0xffFDE047), Color(0xffFACC15)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient gemGradient = LinearGradient(
    colors: [Color(0xffF472B6), Color(0xffC084FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
