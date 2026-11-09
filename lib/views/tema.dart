import 'package:flutter/material.dart';

abstract final class CoresDiskGas {
  static const laranja = Color(0xFFFF781F);
  static const laranjaEscuro = Color(0xFFB34700);
  static const laranjaBotao = Color(0xFFE65C00);
  static const creme = Color(0xFFFFF6EE);
  static const areia = Color(0xFFF3E4D7);
  static const carvao = Color(0xFF2B211B);
  static const cinzaQuente = Color(0xFF7A6A5F);
  static const azulAgua = Color(0xFF1C6EA4);
  static const verde = Color(0xFF1F6B3F);
  static const vermelho = Color(0xFFB71C1C);
  static const ambar = Color(0xFF8A5A00);
  static const azulEscuro = Color(0xFF155A87);
  static const bordaCampo = Color(0xFF8E7D72);
}

abstract final class EstilosDiskGas {
  static const rotulo = TextStyle(
    fontSize: 14,
    color: CoresDiskGas.cinzaQuente,
  );
  static const negrito = TextStyle(fontWeight: FontWeight.w700);
  static const valorVerde = TextStyle(
    color: CoresDiskGas.verde,
    fontWeight: FontWeight.w800,
  );
  static const raioPilula = BorderRadius.all(Radius.circular(999));
}

abstract final class MovimentoDiskGas {
  static const rapido = Duration(milliseconds: 150);
  static const medio = Duration(milliseconds: 220);
  static const tela = Duration(milliseconds: 250);
  static const lento = Duration(milliseconds: 300);
  static const curva = Curves.easeOutCubic;

  static Duration duracao(BuildContext context, Duration normal) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : normal;
}

class TransicaoDeTela extends PageTransitionsBuilder {
  const TransicaoDeTela();

  @override
  Duration get transitionDuration => MovimentoDiskGas.tela;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final curva = CurveTween(curve: MovimentoDiskGas.curva);
    return FadeTransition(
      opacity: animation.drive(curva),
      child: SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(0, 0.03), end: Offset.zero).chain(curva),
        ),
        child: child,
      ),
    );
  }
}

ThemeData criarTema() {
  final esquema =
      ColorScheme.fromSeed(
        seedColor: CoresDiskGas.laranja,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      ).copyWith(
        primary: CoresDiskGas.laranjaEscuro,
        onPrimary: Colors.white,
        primaryContainer: CoresDiskGas.laranjaBotao,
        onPrimaryContainer: Colors.white,
        secondary: CoresDiskGas.azulAgua,
        onSecondary: Colors.white,
        surface: CoresDiskGas.creme,
        onSurface: CoresDiskGas.carvao,
        onSurfaceVariant: CoresDiskGas.cinzaQuente,
        outline: CoresDiskGas.areia,
        error: CoresDiskGas.vermelho,
      );

  final bordaArredondada = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  );
  final base = ThemeData(useMaterial3: true, colorScheme: esquema);
  final textos = base.textTheme.apply(
    bodyColor: CoresDiskGas.carvao,
    displayColor: CoresDiskGas.carvao,
  );

  OutlineInputBorder borda(Color cor, [double largura = 1.2]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cor, width: largura),
      );

  return base.copyWith(
    scaffoldBackgroundColor: CoresDiskGas.creme,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: TransicaoDeTela(),
        TargetPlatform.iOS: TransicaoDeTela(),
      },
    ),
    textTheme: textos.copyWith(
      headlineSmall: textos.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      titleLarge: textos.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      titleMedium: textos.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      bodyMedium: textos.bodyMedium?.copyWith(fontSize: 16),
      bodySmall: textos.bodySmall?.copyWith(fontSize: 14),
      labelLarge: textos.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: CoresDiskGas.creme,
      foregroundColor: CoresDiskGas.carvao,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: CoresDiskGas.carvao,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: CoresDiskGas.laranjaBotao,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: bordaArredondada,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: CoresDiskGas.carvao,
        side: const BorderSide(color: CoresDiskGas.carvao, width: 1.4),
        shape: bordaArredondada,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: CoresDiskGas.laranjaEscuro,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: CoresDiskGas.laranjaBotao,
      foregroundColor: Colors.white,
      extendedTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: borda(CoresDiskGas.bordaCampo),
      enabledBorder: borda(CoresDiskGas.bordaCampo),
      focusedBorder: borda(CoresDiskGas.laranjaEscuro, 2),
      errorBorder: borda(CoresDiskGas.vermelho),
      focusedErrorBorder: borda(CoresDiskGas.vermelho, 2),
      labelStyle: const TextStyle(color: CoresDiskGas.cinzaQuente),
      floatingLabelStyle: const TextStyle(
        color: CoresDiskGas.laranjaEscuro,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: CoresDiskGas.areia),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: CoresDiskGas.carvao,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    expansionTileTheme: const ExpansionTileThemeData(
      shape: Border(),
      collapsedShape: Border(),
      iconColor: CoresDiskGas.laranjaEscuro,
      collapsedIconColor: CoresDiskGas.cinzaQuente,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: CoresDiskGas.creme,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: CoresDiskGas.carvao,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: const DividerThemeData(color: CoresDiskGas.areia),
    chipTheme: ChipThemeData(
      color: WidgetStateProperty.resolveWith(
        (estados) => estados.contains(WidgetState.selected)
            ? CoresDiskGas.laranjaEscuro
            : Colors.white,
      ),
      checkmarkColor: Colors.white,
      side: const BorderSide(color: CoresDiskGas.bordaCampo),
      labelStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: WidgetStateColor.resolveWith(
          (estados) => estados.contains(WidgetState.selected)
              ? Colors.white
              : CoresDiskGas.carvao,
        ),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: CoresDiskGas.carvao,
        selectedBackgroundColor: CoresDiskGas.laranjaEscuro,
        selectedForegroundColor: Colors.white,
        side: const BorderSide(color: CoresDiskGas.bordaCampo),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: CoresDiskGas.laranjaEscuro,
    ),
  );
}
