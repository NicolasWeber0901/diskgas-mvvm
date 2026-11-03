import 'package:diskgas_mvvm/models/cliente.dart';
import 'package:diskgas_mvvm/models/endereco.dart';
import 'package:diskgas_mvvm/models/pedido.dart';
import 'package:diskgas_mvvm/models/produto.dart';
import 'package:diskgas_mvvm/models/situacao_pedido.dart';
import 'package:diskgas_mvvm/services/auth_service.dart';
import 'package:diskgas_mvvm/services/cliente_service.dart';
import 'package:diskgas_mvvm/services/pedido_service.dart';
import 'package:diskgas_mvvm/services/produto_service.dart';
import 'package:diskgas_mvvm/viewmodels/carrinho_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockClienteService extends Mock implements ClienteService {}

class MockProdutoService extends Mock implements ProdutoService {}

class MockPedidoService extends Mock implements PedidoService {}

class FakePedido extends Fake implements Pedido {}

void main() {
  late MockAuthService authService;
  late MockClienteService clienteService;
  late MockProdutoService produtoService;
  late MockPedidoService pedidoService;
  late CarrinhoViewModel viewModel;

  const gas = Produto(
    id: 'gas',
    nome: 'Gás P13',
    preco: 120,
    quantidadeEstoque: 3,
  );

  const enderecoCompleto = Endereco(
    rua: 'Rua Dr. Getúlio Vargas',
    numero: '2822',
    bairro: 'Bela Vista',
    cidade: 'Ibirama',
  );

  Cliente clienteCom(Endereco endereco) => Cliente(
    id: 'uid-maria',
    nome: 'Maria Souza',
    telefone: '47999990000',
    cpf: '52998224725',
    dataNascimento: DateTime(1990, 5, 10),
    endereco: endereco,
    email: 'maria@email.com',
  );

  setUpAll(() => registerFallbackValue(FakePedido()));

  setUp(() async {
    authService = MockAuthService();
    clienteService = MockClienteService();
    produtoService = MockProdutoService();
    pedidoService = MockPedidoService();
    when(() => authService.uidAtual).thenReturn('uid-maria');
    when(() => clienteService.buscar('uid-maria'))
        .thenAnswer((_) async => clienteCom(enderecoCompleto));
    when(() => produtoService.observarProdutos())
        .thenAnswer((_) => Stream.value([gas]));
    when(() => produtoService.buscarProdutos()).thenAnswer((_) async => [gas]);
    when(() => pedidoService.criar(any())).thenAnswer((_) async => 'pedido-1');

    viewModel = CarrinhoViewModel(
      authService,
      clienteService,
      produtoService,
      pedidoService,
    )..iniciar();
    await pumpEventQueue();
  });

  tearDown(() => viewModel.dispose());

  group('RN01: pedido limitado ao estoque disponível', () {
    test('quantidade acima do estoque é recusada', () {
      final aceitou = viewModel.alterarQuantidade(gas, 4);

      expect(aceitou, isFalse);
      expect(viewModel.quantidadeDe(gas), 0);
      expect(viewModel.erro, 'Há apenas 3 de Gás P13 em estoque.');
    });

    test('quantidade dentro do estoque entra no carrinho', () {
      final aceitou = viewModel.alterarQuantidade(gas, 3);

      expect(aceitou, isTrue);
      expect(viewModel.valorTotal, 360);
    });

    test('estoque que diminuiu antes do envio bloqueia o pedido', () async {
      viewModel.alterarQuantidade(gas, 3);
      when(() => produtoService.buscarProdutos()).thenAnswer(
        (_) async => [
          const Produto(
            id: 'gas',
            nome: 'Gás P13',
            preco: 120,
            quantidadeEstoque: 1,
          ),
        ],
      );

      final id = await viewModel.enviarPedido();

      expect(id, isNull);
      expect(viewModel.erro, 'O estoque de Gás P13 mudou: há apenas 1.');
      verifyNever(() => pedidoService.criar(any()));
    });
  });

  group('RN02: endereço cadastrado válido', () {
    test('cliente sem endereço válido não consegue pedir', () async {
      when(() => clienteService.buscar('uid-maria')).thenAnswer(
        (_) async => clienteCom(
          const Endereco(
            rua: 'Rua Dr. Getúlio Vargas',
            numero: '',
            bairro: 'Bela Vista',
            cidade: '',
          ),
        ),
      );
      viewModel.alterarQuantidade(gas, 1);

      final id = await viewModel.enviarPedido();

      expect(id, isNull);
      expect(
        viewModel.erro,
        'Complete o seu endereço no cadastro antes de fazer o pedido.',
      );
      verifyNever(() => pedidoService.criar(any()));
    });

    test('cliente com endereço completo envia o pedido', () async {
      viewModel.alterarQuantidade(gas, 2);

      final id = await viewModel.enviarPedido();

      expect(id, 'pedido-1');
      final pedido =
          verify(() => pedidoService.criar(captureAny())).captured.single
              as Pedido;
      expect(pedido.endereco.textoCompleto, enderecoCompleto.textoCompleto);
      expect(pedido.situacao, SituacaoPedido.aguardando);
      expect(pedido.itens.single.quantidadePedida, 2);
      expect(viewModel.itens, isEmpty);
    });
  });
}
