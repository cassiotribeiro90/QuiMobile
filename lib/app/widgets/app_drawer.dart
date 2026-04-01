import 'package:flutter/material.dart';
import '../core/theme/app_theme_extension.dart';
import '../core/theme/app_colors.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  
  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    final colors = context;
    
    return Drawer(
      backgroundColor: colors.backgroundColor,
      child: Column(
        children: [
          // Header do Drawer com gradiente
          Container(
            height: 140,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.drawerHeaderGradient,
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 40,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'QuiPede',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Itens do menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  index: 0,
                  icon: Icons.storefront_outlined,
                  selectedIcon: Icons.storefront,
                  label: 'Lojas',
                ),
                _buildDrawerItem(
                  context,
                  index: 1,
                  icon: Icons.shopping_bag_outlined,
                  selectedIcon: Icons.shopping_bag,
                  label: 'Meus Pedidos',
                ),
                _buildDrawerItem(
                  context,
                  index: 2,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: 'Meu Perfil',
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  index: 3,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: 'Configurações',
                ),
              ],
            ),
          ),
          
          // Versão do app no rodapé
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Versão 1.0.0',
              style: context.caption.copyWith(color: colors.textHint),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDrawerItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final colors = context;
    final isSelected = selectedIndex == index;
    
    return ListTile(
      leading: Icon(
        isSelected ? selectedIcon : icon,
        color: isSelected ? colors.primaryColor : colors.textSecondary,
        size: 24,
      ),
      title: Text(
        label,
        style: context.bodyMedium.copyWith(
          color: isSelected ? colors.primaryColor : colors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: colors.primarySurface,
      onTap: () {
        onItemSelected(index);
        Navigator.pop(context); // Fecha o drawer
      },
    );
  }
}
