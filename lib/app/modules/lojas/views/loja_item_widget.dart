import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../models/loja_model.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/theme_extensions.dart';
import '../../../widgets/common/app_text.dart';

class LojaItemWidget extends StatelessWidget {
  final Loja loja;

  const LojaItemWidget({super.key, required this.loja});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        // Navega para a home da loja, passando o ID
        Navigator.of(context).pushNamed(Routes.LOJA_HOME, arguments: loja.id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: loja.logo,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: theme.disabledColor.withOpacity(0.1)),
                  errorWidget: (context, url, error) => Center(child: Icon(Icons.store, color: theme.disabledColor)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    loja.nome, 
                    style: textTheme.titleMedium?.copyWith(
                      color: context.textPrimary, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: colorScheme.secondary, size: 15),
                      const SizedBox(width: 4),
                      AppText(
                        loja.nota.toString(),
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold, 
                          color: context.textPrimary
                        ),
                      ),
                      AppText(
                        ' • ${loja.categoria.name}',
                        style: textTheme.bodyMedium?.copyWith(color: context.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    '${loja.tempoEntregaFormatado} • ${loja.taxaEntregaFormatada}',
                    style: textTheme.bodyMedium?.copyWith(color: context.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
