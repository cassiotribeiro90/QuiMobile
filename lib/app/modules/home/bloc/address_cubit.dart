import 'package:flutter_bloc/flutter_bloc.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  AddressCubit() : super(AddressInitial());

  void getCurrentLocation() async {
    emit(AddressLoading());
    // Mock de localização
    await Future.delayed(const Duration(seconds: 1));
    emit(const AddressLoaded(AddressModel(
      street: 'Rua Rio de Janeiro',
      number: '200',
      district: 'Centro',
      city: 'Belo Horizonte',
    )));
  }

  void selectAddress(AddressModel address) {
    emit(AddressLoaded(address));
  }
}
