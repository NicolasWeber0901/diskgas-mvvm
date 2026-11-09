import 'dart:async';

import 'package:diskgas_mvvm/models/endereco.dart';
import 'package:diskgas_mvvm/models/item_pedido.dart';
import 'package:diskgas_mvvm/models/pedido.dart';
import 'package:diskgas_mvvm/models/situacao_pedido.dart';
import 'package:diskgas_mvvm/services/pedido_service.dart';
import 'package:diskgas_mvvm/services/produto_service.dart';
import 'package:diskgas_mvvm/viewmodels/pedidos_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPedidoService extends Mock implements PedidoService {}

class MockProdutoService extends Mock implements ProdutoService {}

void main() {
  late MockPedidoService pedidoService;
  late PedidosViewModel viewModel;
  final agora = DateTime(2026, 11, 6, 15);

  Pedido pedido(
    String id,
    String cliente,
    SituacaoPedido situacao,
    DateTime data,
  ) => Pedido(
    id: id,
    clienteId: 'uid-$id',
    clienteNome: cliente,
    clienteTelefone: '47999990000',
    endereco: const Endereco(
      rua: 'Rua Dr. Getúlio Vargas',
      numero: '2822',
      bairro: 'Bela Vista',
      cidade: 'Ibirama',
    ),
    itens: const [
      ItemPedido(
        produtoId: 'gas',
        nomeProduto: 'Gás P13',
        precoUnitario: 120,
        quantidadePedida: 1,
      ),
    ],
    situacao: situacao,
    dataCriacao: data,
  );

  setUp(() async {
    pedidoService = MockPedidoService();
    final produtoService = MockProdutoService();
    when(() => produtoService.garantirProdutosFixos()).thenAnswer((_) async {});
    when(() => pedidoService.observarTodos()).thenAnswer(
      (_) => Stream.value([
        pedido('1', 'Maria Souza', SituacaoPedido.aguardando, agora),
        pedido(
          '2',
          'Maria Souza',
          SituacaoPedido.entregue,
          agora.subtract(const Duration(days: 3)),
        ),
        pedido(
          '3',
          'Pedro Hoffmann',
          SituacaoPedido.entregue,
          agora.subtract(const Duration(days: 2)),
        ),
        pedido(
          '4',
          'Maria Souza',
          SituacaoPedido.entregue,
          agora.subtract(const Duration(days: 20)),
        ),
      ]),
    );
    viewModel = PedidosViewModel(
      pedidoService,
      produtoService,
      agora: () => agora,
    )..iniciar();
    await pumpEventQueue();
  });

  tearDown(() => viewModel.dispose());

  group('US17: filtrar os pedidos', () {
    test(
      'situação, período e nome combinados mostram só o que atende a todos',
      () {
        viewModel
          ..alternarSituacao(SituacaoPedido.entregue)
          ..escolherPeriodo(PeriodoPedidos.seteDias)
          ..buscar('maria');

        expect(viewModel.pedidosFiltrados.map((p) => p.id), ['2']);
      },
    );

    test('limpar os filtros volta a mostrar todos os pedidos', () {
      viewModel
        ..alternarSituacao(SituacaoPedido.aguardando)
        ..buscar('pedro')
        ..limparFiltros();

      expect(viewModel.pedidosFiltrados, hasLength(4));
      expect(viewModel.filtrando, isFalse);
    });
  });
}
