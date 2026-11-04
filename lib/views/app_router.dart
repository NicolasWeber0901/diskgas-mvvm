import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/cliente_service.dart';
import '../services/pedido_service.dart';
import '../services/produto_service.dart';
import '../viewmodels/acompanhamento_viewmodel.dart';
import '../viewmodels/cadastro_viewmodel.dart';
import '../viewmodels/carrinho_viewmodel.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/sessao_viewmodel.dart';
import 'acompanhamento_view.dart';
import 'cadastro_view.dart';
import 'carregando_view.dart';
import 'carrinho_view.dart';
import 'login_view.dart';
import 'pedidos_view.dart';

/// US01 a US03: leva cada perfil à sua tela inicial.
GoRouter criarRotas(SessaoViewModel sessao) {
  return GoRouter(
    initialLocation: '/carregando',
    refreshListenable: sessao,
    redirect: (context, state) {
      final local = state.matchedLocation;
      String? manterOuIr(bool permitido, String destino) =>
          permitido ? null : destino;
      return switch (sessao.estado) {
        EstadoSessao.carregando ||
        EstadoSessao.falha => manterOuIr(local == '/carregando', '/carregando'),
        EstadoSessao.deslogado => manterOuIr(
          local == '/login' || local == '/cadastro',
          '/login',
        ),
        EstadoSessao.cadastroPendente => manterOuIr(
          local == '/cadastro',
          '/cadastro',
        ),
        EstadoSessao.cliente => manterOuIr(
          local.startsWith('/cliente'),
          '/cliente',
        ),
        EstadoSessao.administrador => manterOuIr(
          local.startsWith('/admin'),
          '/admin',
        ),
      };
    },
    routes: [
      GoRoute(
        path: '/carregando',
        builder: (context, state) => const CarregandoView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => LoginViewModel(context.read<AuthService>()),
          child: const LoginView(),
        ),
      ),
      GoRoute(
        path: '/cadastro',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => CadastroViewModel(
            context.read<AuthService>(),
            context.read<ClienteService>(),
          ),
          child: const CadastroView(),
        ),
      ),
      GoRoute(
        path: '/cliente',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => CarrinhoViewModel(
            context.read<AuthService>(),
            context.read<ClienteService>(),
            context.read<ProdutoService>(),
            context.read<PedidoService>(),
          )..iniciar(),
          child: const CarrinhoView(),
        ),
        routes: [
          GoRoute(
            path: 'pedidos',
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) => AcompanhamentoViewModel(
                context.read<AuthService>(),
                context.read<PedidoService>(),
              )..iniciar(),
              child: const AcompanhamentoView(),
            ),
          ),
        ],
      ),
      GoRoute(path: '/admin', builder: (context, state) => const PedidosView()),
    ],
  );
}
