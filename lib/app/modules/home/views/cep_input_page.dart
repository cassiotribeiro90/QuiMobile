import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quipede/shared/api/api_client.dart';
import 'package:quipede/app/di/dependencies.dart';
import 'package:quipede/app/core/utils/masks.dart';
import '../services/localizacao_service.dart';
import 'endereco_confirmacao_page.dart';
import 'widgets/endereco_card.dart';

class CepInputPage extends StatefulWidget {
  const CepInputPage({super.key});

  @override
  State<CepInputPage> createState() => _CepInputPageState();
}

class _CepInputPageState extends State<CepInputPage> {
  final _cepController = TextEditingController();
  final _localizacaoService = LocalizacaoService(getIt<ApiClient>());
  
  Map<String, dynamic>? _enderecoEncontrado;
  bool _isLoading = false;

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  Future<void> _buscarCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length != 8) return;

    setState(() => _isLoading = true);
    try {
      final response = await _localizacaoService.buscarCep(cep);
      if (response['success'] == true) {
        setState(() {
          _enderecoEncontrado = response['data'];
        });
      } else {
        _showError(response['message'] ?? 'CEP não encontrado.');
      }
    } catch (e) {
      _showError('Erro ao buscar CEP.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _irParaConfirmacao() {
    if (_enderecoEncontrado == null) return;
    
    // ✅ Não persiste nada aqui, apenas navega para a tela de confirmação
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnderecoConfirmacaoPage(
          endereco: _enderecoEncontrado!,
          latitude: (_enderecoEncontrado!['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (_enderecoEncontrado!['longitude'] as num?)?.toDouble() ?? 0.0,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informar CEP')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _cepController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CepInputFormatter(),
              ],
              decoration: InputDecoration(
                labelText: 'CEP',
                hintText: '00000-000',
                suffixIcon: _isLoading 
                  ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(icon: const Icon(Icons.search), onPressed: _buscarCep),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.replaceAll(RegExp(r'\D'), '').length == 8) _buscarCep();
              },
            ),
            const SizedBox(height: 20),
            if (_enderecoEncontrado != null) ...[
              EnderecoCard(
                logradouro: _enderecoEncontrado!['logradouro'] ?? '',
                bairro: _enderecoEncontrado!['bairro'] ?? '',
                cidade: _enderecoEncontrado!['cidade'] ?? '',
                uf: _enderecoEncontrado!['uf'] ?? '',
                cep: _enderecoEncontrado!['cep'] ?? '',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _irParaConfirmacao,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('CONFIRMAR'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
