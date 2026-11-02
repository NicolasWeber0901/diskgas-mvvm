import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/sessao_viewmodel.dart';
import 'app_router.dart';

class DiskGasApp extends StatefulWidget {
  const DiskGasApp({super.key});

  @override
  State<DiskGasApp> createState() => _DiskGasAppState();
}

class _DiskGasAppState extends State<DiskGasApp> {
  late final GoRouter _rotas = criarRotas(context.read<SessaoViewModel>());

  @override
  void dispose() {
    _rotas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Disk Gás e Água',
      routerConfig: _rotas,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
