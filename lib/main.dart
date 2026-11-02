import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'services/cliente_service.dart';
import 'viewmodels/sessao_viewmodel.dart';
import 'views/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;
  final authService = AuthService(
    FirebaseAuth.instance,
    GoogleSignIn.instance,
    firestore,
  );
  final clienteService = ClienteService(firestore);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: authService),
        Provider.value(value: clienteService),
        ChangeNotifierProvider(
          create: (_) => SessaoViewModel(authService)..iniciar(),
        ),
      ],
      child: const DiskGasApp(),
    ),
  );
}
