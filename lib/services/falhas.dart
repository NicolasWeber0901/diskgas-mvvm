/// Erro lançado pelos serviços, com a mensagem pronta para o usuário.
class FalhaServico implements Exception {
  final String mensagem;

  const FalhaServico(this.mensagem);

  @override
  String toString() => mensagem;
}

class FalhaAutenticacao extends FalhaServico {
  const FalhaAutenticacao(super.mensagem);
}

class FalhaConexao extends FalhaServico {
  const FalhaConexao([
    super.mensagem = 'Sem conexão com o servidor. Tente novamente.',
  ]);
}

class FalhaRota extends FalhaServico {
  const FalhaRota([
    super.mensagem = 'Não foi possível calcular a distância até o cliente.',
  ]);
}

class EstoqueInsuficiente extends FalhaServico {
  const EstoqueInsuficiente(String nomeProduto)
    : super('Estoque insuficiente de $nomeProduto.');
}
