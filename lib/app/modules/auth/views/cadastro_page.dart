import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quipede/app/routes/app_routes.dart';
import 'package:quipede/app/core/utils/masks.dart';
import 'package:quipede/app/core/utils/validators.dart';
import 'package:quipede/app/modules/home/bloc/localizacao_cubit.dart';
import 'package:quipede/app/modules/home/bloc/localizacao_state.dart';
import 'package:quipede/app/modules/auth/models/cadastro_models.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _continuar(LocalizacaoCarregada localizacao) {
    if (_formKey.currentState!.validate()) {
      final info = CadastroInfoModel(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        telefone: _telefoneController.text.replaceAll(RegExp(r'\D'), ''),
        senha: _senhaController.text.trim(),
        confirmarSenha: _confirmarSenhaController.text.trim(),
      );
      
      Navigator.pushNamed(
        context, 
        Routes.cadastroEndereco, 
        arguments: info
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF57C00);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Criar conta'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<LocalizacaoCubit, LocalizacaoState>(
        builder: (context, locState) {
          final isEnderecoDefinido = locState is LocalizacaoCarregada;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '📍 Endereço de entrega',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, Routes.onboarding),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isEnderecoDefinido ? Colors.orange.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isEnderecoDefinido ? Colors.orange.shade200 : Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isEnderecoDefinido ? Icons.home_rounded : Icons.location_off_rounded,
                            color: isEnderecoDefinido ? primaryColor : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEnderecoDefinido 
                                    ? locState.enderecoFormatado 
                                    : 'Nenhum endereço definido',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isEnderecoDefinido ? Colors.black87 : Colors.red.shade700,
                                  ),
                                ),
                                if (isEnderecoDefinido)
                                  const Text('Toque para alterar', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Icon(Icons.edit_outlined, size: 20, color: isEnderecoDefinido ? primaryColor : Colors.red),
                        ],
                      ),
                    ),
                  ),
                  
                  if (!isEnderecoDefinido)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        '⚠️ Defina um endereço para continuar',
                        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Dados Pessoais',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  _buildField(
                    controller: _nomeController,
                    label: 'Nome completo',
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.isEmpty) ? 'Informe seu nome' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildField(
                    controller: _emailController,
                    label: 'E-mail',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: AppValidators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildField(
                    controller: _telefoneController,
                    label: 'Telefone',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      PhoneInputFormatter(),
                    ],
                    validator: AppValidators.validatePhone,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildField(
                    controller: _senhaController,
                    label: 'Senha',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Informe uma senha';
                      if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    controller: _confirmarSenhaController,
                    label: 'Confirmar senha',
                    icon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Confirme sua senha';
                      if (value != _senhaController.text) return 'As senhas não coincidem';
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),
                  
                  ElevatedButton(
                    onPressed: isEnderecoDefinido ? () => _continuar(locState as LocalizacaoCarregada) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('CONTINUAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Ao continuar, você concorda com nossos Termos de Uso.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}
