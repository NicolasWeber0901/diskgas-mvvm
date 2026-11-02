import 'package:diskgas_mvvm/services/auth_service.dart';
import 'package:diskgas_mvvm/services/falhas.dart';
import 'package:diskgas_mvvm/viewmodels/login_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService authService;
  late LoginViewModel viewModel;

  setUp(() {
    authService = MockAuthService();
    viewModel = LoginViewModel(authService);
  });

  group('RF17: login com e-mail e senha', () {
    test('com a senha correta, entra sem erro', () async {
      when(() => authService.entrarComEmail('antonio@diskgas.com', 'senha123'))
          .thenAnswer((_) async => 'uid-antonio');

      final entrou = await viewModel.entrarComEmail(
        'antonio@diskgas.com',
        'senha123',
      );

      expect(entrou, isTrue);
      expect(viewModel.erro, isNull);
    });

    test('com a senha errada, exibe erro e não entra', () async {
      when(() => authService.entrarComEmail('antonio@diskgas.com', 'errada'))
          .thenThrow(const FalhaAutenticacao('E-mail ou senha inválidos.'));

      final entrou = await viewModel.entrarComEmail(
        'antonio@diskgas.com',
        'errada',
      );

      expect(entrou, isFalse);
      expect(viewModel.erro, 'E-mail ou senha inválidos.');
    });
  });
}
