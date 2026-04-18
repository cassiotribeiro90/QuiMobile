import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quipede/app/routes/app_routes.dart';
import 'package:quipede/shared/api/api_client.dart';
import 'package:quipede/app/di/dependencies.dart';
import '../bloc/localizacao_cubit.dart';
import '../services/localizacao_service.dart';
import 'widgets/endereco_card.dart';

class EnderecoConfirmacaoPage extends StatefulWidget {
  final Map<String, dynamic> endereco;
  final double latitude;
  final double longitude;

  const EnderecoConfirmacaoPage({
    super.key,
    required this.endereco,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<EnderecoConfirmacaoPage> createState() => _EnderecoConfirmacaoPageState();
}

class _EnderecoConfirmacaoPageState extends State<EnderecoConfirmacaoPage> {
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _localizacaoService = LocalizacaoService(getIt<ApiClient>());
  bool _isLoading = false;

  @override
  void dispose() {
    _numeroController.dispose();
    _complementoController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (_numeroController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o número.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payload = {
        'logradouro': widget.endereco['logradouro'] ?? widget.endereco['descricao'],
        'numero': _numeroController.text.trim(),
        'bairro': widget.endereco['bairro'],
        'cidade': widget.endereco['cidade'],
        'uf': widget.endereco['uf'],
        'cep': widget.endereco['cep'],
        'complemento': _complementoController.text.trim().isEmpty ? null : _complementoController.text.trim(),
        'referencia': _referenciaController.text.trim().isEmpty ? null : _referenciaController.text.trim(),
        'latitude': widget.latitude,
        'longitude': widget.longitude,
      };

      final response = await _localizacaoService.confirmarEndereco(payload);

      if (response['success'] == true && mounted) {
        final data = response['data'];
        
        // ✅ Persistência e atualização do estado global acontecem APENAS após resposta de sucesso da API
        context.read<LocalizacaoCubit>().definirLocalizacaoManual(
          latitude: (data['latitude'] as num).toDouble(),
          longitude: (data['longitude'] as num).toDouble(),
          enderecoFormatado: '${data['logradouro']}, ${data['numero']}',
          referencia: data['referencia'],
        );
        
        Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
      } else if (mounted) {
        _showError(response['message'] ?? 'Erro ao confirmar endereço.');
      }
    } catch (e) {
      _showError('Erro ao processar confirmação: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Endereço')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                ),
                const SizedBox(height: 24),
                EnderecoCard(
                  logradouro: widget.endereco['logradouro'] ?? widget.endereco['descricao'] ?? '',
                  bairro: widget.endereco['bairro'] ?? '',
                  cidade: widget.endereco['cidade'] ?? '',
                  uf: widget.endereco['uf'] ?? '',
                  cep: widget.endereco['cep'] ?? '',
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _numeroController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Número', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _complementoController,
                        decoration: const InputDecoration(labelText: 'Complemento (opcional)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _referenciaController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Ponto de referência (opcional)',
                    hintText: 'Ex: portão verde, próximo ao mercado',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _confirmar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('CONFIRMAR E CONTINUAR', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
