import 'package:flutter/material.dart';
import '../models/loja.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/text_utils.dart';

class LojaItemWidget extends StatelessWidget {
  final Loja loja;

  const LojaItemWidget({super.key, required this.loja});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        onTap: () => Navigator.pushNamed(
          context, 
          Routes.LOJA_HOME, 
          arguments: loja.id
        ),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(loja.logo ?? ''),
        ),
        title: Text(loja.nome),
        subtitle: Text(loja.categoria),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            Text(loja.notaMedia.toString()),
          ],
        ),
      ),
    );
  }
}
