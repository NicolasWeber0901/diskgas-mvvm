import 'package:diskgas_mvvm/models/cliente.dart';
import 'package:diskgas_mvvm/models/endereco.dart';
import 'package:diskgas_mvvm/models/item_pedido.dart';
import 'package:diskgas_mvvm/models/pedido.dart';
import 'package:diskgas_mvvm/models/situacao_pedido.dart';
import 'package:diskgas_mvvm/services/cliente_service.dart';
import 'package:diskgas_mvvm/services/pedido_service.dart';
import 'package:diskgas_mvvm/viewmodels/perfil_cliente_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockClienteService extends Mock implements ClienteService {}

class MockPedidoService extends Mock implements PedidoService {}

void main() {
  const endereco = Endereco(
    rua: 'Rua Dr. Getúlio Vargas',
    numero: '2822',
    bairro: 'Bela Vista',
    cidade: 'Ibirama',
  );

  Pedido pedido(
    String id,
    SituacaoPedido situacao,
    DateTime data,
    int pedida, {
    int? entregue,
  }) => Pedido(
    id: id,
    clienteId: 'uid-maria',
    clienteNome: 'Maria Souza',
    clienteTelefone: '47999112233',
    endereco: endereco,
    itens: [
      ItemPedido(
        produtoId: 'gas',
        nomeProduto: 'Gás P13',
        precoUnitario: 120,
        quantidadePedida: pedida,
        quantidadeEntregue: entregue,
      ),
    ],
    situacao: situacao,
    dataCriacao: data,
  );

  group('US16: perfil do cliente', () {
    test('o resumo conta os pedidos e soma o gasto só dos entregues, '
        'pela quantidade entregue', () async {
      final clienteService = MockClienteService();
      final pedidoService = MockPedidoService();
      when(() => clienteService.buscar('uid-maria')).thenAnswer(
        (_) async => Cliente(
          id: 'uid-maria',
          nome: 'Maria Souza',
          telefone: '47999112233',
          cpf: '52601815906',
          dataNascimento: DateTime(1975, 3, 12),
          endereco: endereco,
          email: 'maria.souza@example.com',
        ),
      );
      when(() => pedidoService.observarPedidosDoCliente('uid-maria'))
          .thenAnswer(
            (_) => Stream.value([
              pedido(
                '1',
                SituacaoPedido.entregue,
                DateTime(2026, 11, 1),
                1,
                entregue: 2,
              ),
              pedido('2', SituacaoPedido.recusado, DateTime(2026, 11, 3), 3),
              pedido('3', SituacaoPedido.aguardando, DateTime(2026, 11, 5), 1),
            ]),
          );

      final viewModel = PerfilClienteViewModel(clienteService, pedidoService)
        ..iniciar('uid-maria');
      await pumpEventQueue();

      expect(viewModel.cliente?.nome, 'Maria Souza');
      expect(viewModel.totalDePedidos, 3);
      expect(viewModel.pedidosEntregues, 1);
      expect(viewModel.totalGasto, 240);
      expect(viewModel.ultimoPedido, DateTime(2026, 11, 5));
      expect(viewModel.pedidos.first.id, '3');
      viewModel.dispose();
    });
  });
}
