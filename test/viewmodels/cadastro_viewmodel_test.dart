import 'package:diskgas_mvvm/models/cliente.dart';
import 'package:diskgas_mvvm/models/endereco.dart';
import 'package:diskgas_mvvm/services/auth_service.dart';
import 'package:diskgas_mvvm/services/cliente_service.dart';
import 'package:diskgas_mvvm/viewmodels/cadastro_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockClienteService extends Mock implements ClienteService {}

class FakeCliente extends Fake implements Cliente {}

void main() {
  late MockAuthService authService;
  late MockClienteService clienteService;
  late CadastroViewModel viewModel;

  const endereco = Endereco(
    rua: 'Rua Dr. Getúlio Vargas',
    numero: '2822',
    bairro: 'Bela Vista',
    cidade: 'Ibirama',
  );

  setUpAll(() => registerFallbackValue(FakeCliente()));

  setUp(() {
    authService = MockAuthService();
    clienteService = MockClienteService();
    when(() => authService.uidAtual).thenReturn(null);
    viewModel = CadastroViewModel(authService, clienteService);
  });

  Future<bool> cadastrarCom(String cpf) {
    return viewModel.cadastrar(
      nome: 'Maria Souza',
      telefone: '47999990000',
      cpf: cpf,
      dataNascimento: DateTime(1990, 5, 10),
      endereco: endereco,
      email: 'maria@email.com',
      senha: 'senha123',
    );
  }

  group('RN03: CPF válido', () {
    test('com CPF inválido, recusa o cadastro', () async {
      final cadastrou = await cadastrarCom('123.456.789-00');

      expect(cadastrou, isFalse);
      expect(viewModel.errosDosCampos['cpf'], 'CPF inválido');
      verifyNever(() => authService.criarConta(any(), any()));
      verifyNever(() => clienteService.salvar(any()));
    });

    test('com CPF válido, cria a conta e salva o cliente', () async {
      when(() => clienteService.cpfJaCadastrado('52998224725'))
          .thenAnswer((_) async => false);
      when(() => authService.criarConta('maria@email.com', 'senha123'))
          .thenAnswer((_) async => 'uid-maria');
      when(() => clienteService.salvar(any())).thenAnswer((_) async {});

      final cadastrou = await cadastrarCom('529.982.247-25');

      expect(cadastrou, isTrue);
      final salvo =
          verify(() => clienteService.salvar(captureAny())).captured.single
              as Cliente;
      expect(salvo.id, 'uid-maria');
      expect(salvo.cpf, '52998224725');
    });
  });
}
