import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:qui/app/modules/lojas/cubit/lojas_cubit.dart';
import 'package:qui/app/modules/lojas/cubit/lojas_state.dart';
import 'package:qui/app/models/loja_model.dart';

void main() {
  // Garante que os recursos do Flutter (como o rootBundle para carregar assets)
  // estejam disponíveis para os testes.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LojasCubit', () {
    // Teste 1: Verifica o estado inicial do Cubit
    test('o estado inicial deve ser LojasInitial', () {
      expect(LojasCubit().state, equals(LojasInitial()));
    });

    // Teste 2: Simula o cenário de sucesso
    blocTest<LojasCubit, LojasState>(
      'deve emitir [LojasLoading, LojasLoaded] quando loadLojas for bem-sucedido',
      build: () => LojasCubit(),
      act: (cubit) => cubit.loadLojas(),
      expect: () => [
        isA<LojasLoading>(),
        isA<LojasLoaded>(), // Apenas verificamos o tipo do estado
      ],
    );

    // Teste 3: Verifica se a lista de lojas não está vazia no estado de sucesso
    blocTest<LojasCubit, LojasState>(
      'deve emitir LojasLoaded com uma lista de lojas não vazia',
      build: () => LojasCubit(),
      act: (cubit) => cubit.loadLojas(),
      expect: () => [
        LojasLoading(),
        // Aqui podemos ser mais específicos e verificar o conteúdo do estado
        predicate<LojasLoaded>((state) => state.lojas.isNotEmpty, 'a lista de lojas não deve ser vazia'),
      ],
    );

    // Teste 4: Simula o cenário de erro (arquivo não encontrado)
    // (Este teste é mais avançado, pois requer "mockar" o rootBundle,
    // mas o bloc_test nos ajuda a validar a emissão de estados de erro)
    blocTest<LojasCubit, LojasState>(
      'deve emitir [LojasLoading, LojasError] se o arquivo de asset não for encontrado',
      build: () => LojasCubit(),
      // No "act", forçamos um erro ao tentar carregar um arquivo que não existe
      act: (cubit) async {
        // Sobrescrevemos a forma como o rootBundle funciona para este teste específico
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          MethodChannel('flutter/assets'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'loadString') {
              // Forçamos uma exceção, simulando que o arquivo não foi encontrado
              throw Exception('Asset not found');
            }
            return null;
          },
        );
        await cubit.loadLojas();
      },
      expect: () => [
        isA<LojasLoading>(),
        isA<LojasError>(),
      ],
      // Limpamos o mock após o teste
      tearDown: () {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          MethodChannel('flutter/assets'),
          null,
        );
      },
    );
  });
}
