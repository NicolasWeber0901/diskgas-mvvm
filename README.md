# Disk Gás e Água: versão MVVM

Aplicativo Flutter do TCC "Avaliação comparativa entre MVVM e Clean Architecture
em Flutter" (Engenharia de Software, UDESC/CEAVI). Esta é a versão MVVM, que
representa o sistema existente; a versão Clean é a refatoração dela.

## Estrutura

```
lib/
  main.dart     monta as dependências e o app
  models/       Cliente, Administrador, Produto, Pedido, ItemPedido, Coordenada e tipos auxiliares
  services/     Firebase Auth e conta Google, Firestore e Routes API
  viewmodels/   estado das telas e regras de negócio (RN01 a RN06)
  views/        telas, rotas e widgets
test/           testes unitários dos ViewModels (mocktail)
```

O caminho das dependências é View → ViewModel → serviço.

## Como rodar

1. Flutter 3.47.8 (Dart 3.13.7).
2. No console do Firebase, ative o login por e-mail e senha e pelo Google, crie
   o banco Firestore e registre o SHA-1 da chave de assinatura no app Android.
3. Copie o `google-services.json` do app Android `br.udesc.ceavi.diskgas.mvvm`
   para `android/app/`. Ele não vai para o repositório.
4. Cole o `firestore.rules` em Firestore > Regras.
5. Crie o administrador: cadastre a conta no Firebase Authentication e, no
   Firestore, o documento `usuarios/{uid}` com `perfil: "administrador"`, `nome`
   e `email`.
6. No Google Cloud, ative a Routes API e o Maps SDK for Android e crie uma chave
   restrita a essas duas APIs.
7. Crie o `dart_defines.json` na raiz do projeto com
   `{"ROUTES_API_KEY": "<chave>"}` e acrescente `MAPS_API_KEY=<chave>` ao
   `android/local.properties`. Nenhum dos dois vai para o repositório.
8. `flutter run --dart-define-from-file=dart_defines.json`

## Funcionalidades

- Cliente: cadastro, login, carrinho, envio do pedido e acompanhamento.
- Administrador: pedidos com filtros (US17), detalhe com distância, tempo e mapa
  da rota (`computeRoutes` da Routes API e Maps SDK for Android), aceite, recusa,
  finalização, estoque e consulta de clientes com perfil e histórico (US16).
- Os produtos Gás P13 e Água mineral 20 L são criados automaticamente quando o
  administrador entra no app, caso ainda não existam.

## Testes

```
flutter test
```
