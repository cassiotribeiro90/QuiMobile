import 'package:mockito/annotations.dart';
import 'package:quipede/app/modules/lojas_list/repository/loja_repository.dart';
import 'package:quipede/app/modules/loja_home/repository/loja_repository.dart';

@GenerateMocks([
  LojaRepository,
  LojaHomeRepository,
])
void main() {}
