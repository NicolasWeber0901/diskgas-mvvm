# Disk Gás e Água: versão MVVM

Aplicativo Flutter do TCC "Avaliação comparativa entre MVVM e Clean Architecture
em Flutter" (Engenharia de Software, UDESC/CEAVI). Esta é a versão MVVM, que
representa o sistema existente; a versão Clean é a refatoração dela.

## Estrutura

```
lib/
  main.dart     monta as dependências e o app
  models/       Cliente, Administrador, Produto, Pedido, ItemPedido e tipos auxiliares
  services/     Firebase Auth e conta Google, Firestore e Routes API
  viewmodels/   estado das telas e regras de negócio (RN01 a RN06)
  views/        telas, rotas e widgets
test/           testes unitários dos ViewModels (mocktail)
```

O caminho das dependências é View → ViewModel → serviço.

## Como rodar

1. Flutter 3.47.8 (Dart 3.13.7).
2. Copie o `google-services.json` do app Android `br.udesc.ceavi.diskgas.mvvm`
   (console do Firebase) para `android/app/`. Ele não vai para o repositório.
3. Cole o `firestore.rules` em Firestore > Regras.
4. `flutter run`

## Testes

```
flutter test
```
