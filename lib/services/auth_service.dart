import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/perfil.dart';
import 'falhas.dart';

/// US01 a US03: login com e-mail e senha ou com a conta Google (RF17, RNF04).
class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  bool _googleIniciado = false;

  AuthService(this._auth, this._googleSignIn, this._firestore);

  String? get uidAtual => _auth.currentUser?.uid;

  String? get emailAtual => _auth.currentUser?.email;

  Stream<String?> observarUsuario() =>
      _auth.authStateChanges().map((usuario) => usuario?.uid);

  Future<String> entrarComEmail(String email, String senha) async {
    try {
      final credencial = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return credencial.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw _traduzir(e);
    }
  }

  Future<String?> entrarComGoogle() async {
    try {
      if (!_googleIniciado) {
        await _googleSignIn.initialize();
        _googleIniciado = true;
      }
      final conta = await _googleSignIn.authenticate();
      final credencial = GoogleAuthProvider.credential(
        idToken: conta.authentication.idToken,
      );
      final resultado = await _auth.signInWithCredential(credencial);
      return resultado.user!.uid;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw const FalhaAutenticacao('Não foi possível entrar com o Google.');
    } on FirebaseAuthException catch (e) {
      throw _traduzir(e);
    }
  }

  Future<String> criarConta(String email, String senha) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return credencial.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw _traduzir(e);
    }
  }

  Future<Perfil?> buscarPerfil(String uid) async {
    try {
      final documento = await _firestore.collection('usuarios').doc(uid).get();
      final perfil = documento.data()?['perfil'] as String?;
      return perfil == null ? null : Perfil.values.byName(perfil);
    } on FirebaseException {
      throw const FalhaConexao();
    }
  }

  Future<void> sair() async {
    await _auth.signOut();
    if (_googleIniciado) await _googleSignIn.signOut();
  }

  FalhaServico _traduzir(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'invalid-email':
      case 'user-not-found':
      case 'wrong-password':
        return const FalhaAutenticacao('E-mail ou senha inválidos.');
      case 'email-already-in-use':
        return const FalhaAutenticacao('Este e-mail já está cadastrado.');
      case 'weak-password':
        return const FalhaAutenticacao(
          'A senha deve ter no mínimo seis caracteres.',
        );
      case 'network-request-failed':
        return const FalhaConexao();
      default:
        return FalhaAutenticacao('Não foi possível entrar (${e.code}).');
    }
  }
}
