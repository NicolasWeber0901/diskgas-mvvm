import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/pedido.dart';
import '../models/situacao_pedido.dart';
import '../services/falhas.dart';
import '../services/pedido_service.dart';
import '../services/produto_service.dart';
import '../services/rota_service.dart';

/// US11 a US15, com as regras RN04, RN05 e RN06.
class DetalhePedidoViewModel extends ChangeNotifier {
  final PedidoService _pedidoService;
  final RotaService _rotaService;
  final ProdutoService _produtoService;
  StreamSubscription<Pedido?>? _inscricao;
  bool _rotaSolicitada = false;
  bool _descartado = false;

  Pedido? pedido;
  bool carregando = true;
  bool processando = false;
  bool calculandoRota = false;
  String? avisoRota;
  String? erro;

  DetalhePedidoViewModel(
    this._pedidoService,
    this._rotaService,
    this._produtoService,
  );

  void iniciar(String pedidoId) {
    _inscricao = _pedidoService
        .observarPedido(pedidoId)
        .listen(
          (atual) {
            pedido = atual;
            carregando = false;
            notifyListeners();
            // RF16: a distância é consultada uma única vez por pedido.
            if (atual != null &&
                atual.situacao == SituacaoPedido.aguardando &&
                atual.deslocamento == null &&
                !_rotaSolicitada) {
              _rotaSolicitada = true;
              _calcularRota(atual);
            }
          },
          onError: (Object _) {
            carregando = false;
            erro = const FalhaConexao().mensagem;
            notifyListeners();
          },
        );
  }

  Future<void> _calcularRota(Pedido atual) async {
    calculandoRota = true;
    notifyListeners();
    try {
      final deslocamento = await _rotaService.calcularDeslocamento(
        atual.endereco.textoCompleto,
      );
      await _pedidoService.gravarDeslocamento(atual.id, deslocamento);
    } on FalhaServico catch (e) {
      avisoRota = e.mensagem;
    } finally {
      calculandoRota = false;
      if (!_descartado) notifyListeners();
    }
  }

  Future<bool> aceitar(String tempoTexto) async {
    final atual = pedido;
    if (atual == null || atual.situacao != SituacaoPedido.aguardando) {
      return _falhar('Somente pedidos aguardando podem ser aceitos.');
    }
    // RN06: o aceite exige um tempo estimado maior que zero.
    final tempo = int.tryParse(tempoTexto.trim());
    if (tempo == null || tempo <= 0) {
      return _falhar('Informe um tempo estimado maior que zero.');
    }
    return _executar(() => _pedidoService.aceitar(atual.id, tempo));
  }

  Future<bool> ampliarTempo(String minutosTexto) async {
    final atual = pedido;
    // RN06: só o pedido aceito pode ter o tempo ampliado.
    if (atual == null || atual.situacao != SituacaoPedido.aceito) {
      return _falhar('Somente pedidos aceitos podem ter o tempo ampliado.');
    }
    final minutos = int.tryParse(minutosTexto.trim());
    if (minutos == null || minutos <= 0) {
      return _falhar('Informe os minutos a mais, maiores que zero.');
    }
    return _executar(() => _pedidoService.ampliarTempo(atual.id, minutos));
  }

  Future<bool> recusar(String motivo) async {
    final atual = pedido;
    if (atual == null || atual.situacao != SituacaoPedido.aguardando) {
      return _falhar('Somente pedidos aguardando podem ser recusados.');
    }
    // RN05: a recusa exige o motivo.
    final motivoLimpo = motivo.trim();
    if (motivoLimpo.isEmpty) {
      return _falhar('Informe o motivo da recusa.');
    }
    return _executar(() => _pedidoService.recusar(atual.id, motivoLimpo));
  }

  Future<bool> finalizarEntrega(Map<String, String> quantidadesTexto) async {
    final atual = pedido;
    if (atual == null || atual.situacao != SituacaoPedido.aceito) {
      return _falhar('Somente pedidos aceitos podem ser finalizados.');
    }
    final quantidades = <String, int>{};
    for (final item in atual.itens) {
      final texto =
          quantidadesTexto[item.produtoId] ?? '${item.quantidadePedida}';
      final quantidade = int.tryParse(texto.trim());
      if (quantidade == null || quantidade < 0) {
        return _falhar('As quantidades entregues não podem ser negativas.');
      }
      quantidades[item.produtoId] = quantidade;
    }

    return _executar(() async {
      // RN04: a baixa usa as quantidades entregues, que podem passar das
      // pedidas se houver estoque.
      final estoque = {
        for (final produto in await _produtoService.buscarProdutos())
          produto.id: produto.quantidadeEstoque,
      };
      for (final item in atual.itens) {
        final disponivel = estoque[item.produtoId] ?? 0;
        if (quantidades[item.produtoId]! > disponivel) {
          throw FalhaServico(
            'Estoque insuficiente de ${item.nomeProduto}: '
            'há apenas $disponivel.',
          );
        }
      }
      await _pedidoService.finalizarEntrega(atual, quantidades);
    });
  }

  void limparErro() {
    if (_descartado) return;
    erro = null;
    notifyListeners();
  }

  bool _falhar(String mensagem) {
    erro = mensagem;
    notifyListeners();
    return false;
  }

  Future<bool> _executar(Future<void> Function() acao) async {
    processando = true;
    erro = null;
    notifyListeners();
    try {
      await acao();
      return true;
    } on FalhaServico catch (e) {
      erro = e.mensagem;
      return false;
    } finally {
      processando = false;
      if (!_descartado) notifyListeners();
    }
  }

  @override
  void dispose() {
    _descartado = true;
    _inscricao?.cancel();
    super.dispose();
  }
}
