import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../routes/app_routes.dart';
import '../../home/bloc/address_cubit.dart';
import '../../home/bloc/address_state.dart';

class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onAddressTap;
  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;

  const CustomHomeAppBar({
    super.key,
    required this.onAddressTap,
    required this.onSearchTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.grey[900],
      title: _buildAddressTitle(context),
      actions: [
        IconButton(
          icon: Icon(Icons.search_outlined, color: Colors.grey[700]),
          onPressed: onSearchTap,
          tooltip: 'Buscar e filtrar',
        ),
        IconButton(
          icon: Icon(Icons.receipt_long_outlined, color: Colors.grey[700]),
          onPressed: () => Navigator.pushNamed(context, Routes.PEDIDOS),
          tooltip: 'Meus Pedidos',
        ),
        IconButton(
          icon: Icon(Icons.person_outline, color: Colors.grey[700]),
          onPressed: () => Navigator.pushNamed(context, Routes.PERFIL),
          tooltip: 'Perfil',
        ),
      ],
    );
  }

  Widget _buildAddressTitle(BuildContext context) {
    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        String addressText = "Selecionar endereço";
        if (state is AddressLoaded && state.address != null) {
          addressText = state.address!.formattedShort;
        }

        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, Routes.ENDERECOS),
          behavior: HitTestBehavior.opaque,
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  size: 18,
                  color: Colors.orange[700],
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    addressText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[900],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
