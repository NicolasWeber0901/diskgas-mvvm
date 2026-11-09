import 'dart:async';

import 'package:diskgas_mvvm/models/deslocamento.dart';
import 'package:diskgas_mvvm/models/endereco.dart';
import 'package:diskgas_mvvm/models/item_pedido.dart';
import 'package:diskgas_mvvm/models/pedido.dart';
import 'package:diskgas_mvvm/models/produto.dart';
import 'package:diskgas_mvvm/models/situacao_pedido.dart';
import 'package:diskgas_mvvm/services/falhas.dart';
import 'package:diskgas_mvvm/services/pedido_service.dart';
import 'package:diskgas_mvvm/services/produto_service.dart';
import 'package:diskgas_mvvm/services/rota_service.dart';
import 'package:diskgas_mvvm/viewmodels/detalhe_pedido_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPedidoService extends Mock implements PedidoService {}

class MockRotaService extends Mock implements RotaService {}

class MockProdutoService extends Mock implements ProdutoService {}

class FakePedido extends Fake implements Pedido {}

void main() {
  late MockPedidoService pedidoService;
  late MockRotaService rotaService;
  late MockProdutoService produtoService;
  late StreamController<Pedido?> pedidoObservado;
  late DetalhePedidoViewModel viewModel;

  const endereco = Endereco(
    rua: 'Rua Dr. Getúlio Vargas',
    numero: '2822',
    bairro: 'Bela Vista',
    cidade: 'Ibirama',
  );

  const deslocamento = Deslocamento(
    distanciaMetros: 12400,
    duracaoSegundos: 900,
    polilinha: '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
  );

  Pedido pedidoCom({
    SituacaoPedido situacao = SituacaoPedido.aguardando,
    Deslocamento? comDeslocamento,
  }) => Pedido(
    id: 'pedido-1',
    clienteId: 'uid-maria',
    clienteNome: 'Maria Souza',
    clienteTelefone: '47999990000',
    endereco: endereco,
    itens: const [
      ItemPedido(
        produtoId: 'gas',
        nomeProduto: 'Gás P13',
        precoUnitario: 120,
        quantidadePedida: 2,
      ),
    ],
    situacao: situacao,
    dataCriacao: DateTime(2026, 11, 4, 10),
    deslocamento: comDeslocamento,
    tempoEstimadoMinutos: situacao == SituacaoPedido.aceito ? 30 : null,
  );

  Produto gasCom(int estoque) => Produto(
    id: 'gas',
    nome: 'Gás P13',
    preco: 120,
    quantidadeEstoque: estoque,
  );

  Future<void> abrir(Pedido pedido) async {
    viewModel.iniciar(pedido.id);
    pedidoObservado.add(pedido);
    await pumpEventQueue();
  }

  setUpAll(() {
    registerFallbackValue(FakePedido());
    registerFallbackValue(deslocamento);
  });

  setUp(() {
    pedidoService = MockPedidoService();
    rotaService = MockRotaService();
    produtoService = MockProdutoService();
    pedidoObservado = StreamController<Pedido?>();
    when(() => pedidoService.observarPedido(any()))
        .thenAnswer((_) => pedidoObservado.stream);
    when(() => rotaService.calcularDeslocamento(any()))
        .thenAnswer((_) async => deslocamento);
    when(() => pedidoService.gravarDeslocamento(any(), any()))
        .thenAnswer((_) async {});
    when(() => pedidoService.aceitar(any(), any())).thenAnswer((_) async {});
    when(() => pedidoService.ampliarTempo(any(), any()))
        .thenAnswer((_) async {});
    when(() => pedidoService.recusar(any(), any())).thenAnswer((_) async {});
    when(() => pedidoService.finalizarEntrega(any(), any()))
        .thenAnswer((_) async {});

    viewModel = DetalhePedidoViewModel(
      pedidoService,
      rotaService,
      produtoService,
    );
  });

  tearDown(() {
    viewModel.dispose();
    pedidoObservado.close();
  });

  group('RF16: distância e tempo até o cliente', () {
    test('pedido aguardando sem distância consulta a Routes API e grava o resultado', () async {
      await abrir(pedidoCom());

      verify(() => rotaService.calcularDeslocamento(endereco.textoCompleto))
          .called(1);
      verify(() => pedidoService.gravarDeslocamento('pedido-1', deslocamento))
          .called(1);
    });

    test('pedido que já tem a distância não consulta de novo', () async {
      await abrir(pedidoCom(comDeslocamento: deslocamento));

      verifyNever(() => rotaService.calcularDeslocamento(any()));
    });

    test(
      'falha da Routes API mostra o aviso e o pedido ainda pode ser aceito',
      () async {
        when(() => rotaService.calcularDeslocamento(any()))
            .thenThrow(const FalhaRota());

        await abrir(pedidoCom());

        expect(viewModel.avisoRota, const FalhaRota().mensagem);
        expect(await viewModel.aceitar('30'), isTrue);
        verify(() => pedidoService.aceitar('pedido-1', 30)).called(1);
      },
    );
  });

  group('RN06: tempo estimado no aceite e na ampliação', () {
    test('aceite sem tempo estimado é bloqueado', () async {
      await abrir(pedidoCom(comDeslocamento: deslocamento));

      expect(await viewModel.aceitar(''), isFalse);
      expect(viewModel.erro, 'Informe um tempo estimado maior que zero.');
      verifyNever(() => pedidoService.aceitar(any(), any()));
    });

    test('ampliação soma os minutos ao pedido aceito', () async {
      await abrir(pedidoCom(situacao: SituacaoPedido.aceito));

      expect(await viewModel.ampliarTempo('15'), isTrue);
      verify(() => pedidoService.ampliarTempo('pedido-1', 15)).called(1);
    });

    test('pedido aguardando não pode ter o tempo ampliado', () async {
      await abrir(pedidoCom(comDeslocamento: deslocamento));

      expect(await viewModel.ampliarTempo('15'), isFalse);
      expect(
        viewModel.erro,
        'Somente pedidos aceitos podem ter o tempo ampliado.',
      );
      verifyNever(() => pedidoService.ampliarTempo(any(), any()));
    });
  });

  group('RN05: motivo da recusa', () {
    test('recusa sem motivo é bloqueada', () async {
      await abrir(pedidoCom(comDeslocamento: deslocamento));

      expect(await viewModel.recusar('   '), isFalse);
      expect(viewModel.erro, 'Informe o motivo da recusa.');
      verifyNever(() => pedidoService.recusar(any(), any()));
    });

    test('recusa com motivo grava o motivo', () async {
      await abrir(pedidoCom(comDeslocamento: deslocamento));

      expect(await viewModel.recusar('  Fora da área de entrega '), isTrue);
      verify(() => pedidoService.recusar('pedido-1', 'Fora da área de entrega'))
          .called(1);
    });
  });

  group('RN04: baixa com a quantidade entregue', () {
    test('entrega maior que a pedida é aceita se houver estoque', () async {
      final pedido = pedidoCom(situacao: SituacaoPedido.aceito);
      when(() => produtoService.buscarProdutos())
          .thenAnswer((_) async => [gasCom(5)]);
      await abrir(pedido);

      expect(await viewModel.finalizarEntrega({'gas': '3'}), isTrue);
      verify(() => pedidoService.finalizarEntrega(pedido, {'gas': 3}))
          .called(1);
    });

    test('entrega acima do estoque é bloqueada e nada é baixado', () async {
      when(() => produtoService.buscarProdutos())
          .thenAnswer((_) async => [gasCom(1)]);
      await abrir(pedidoCom(situacao: SituacaoPedido.aceito));

      expect(await viewModel.finalizarEntrega({'gas': '2'}), isFalse);
      expect(viewModel.erro, 'Estoque insuficiente de Gás P13: há apenas 1.');
      verifyNever(() => pedidoService.finalizarEntrega(any(), any()));
    });
  });
}
