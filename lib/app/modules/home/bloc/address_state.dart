import 'package:equatable/equatable.dart';

class AddressModel extends Equatable {
  final String street;
  final String number;
  final String district;
  final String city;

  const AddressModel({
    required this.street,
    required this.number,
    required this.district,
    required this.city,
  });

  String get formattedShort => '$street, $number';

  @override
  List<Object?> get props => [street, number, district, city];
}

abstract class AddressState extends Equatable {
  const AddressState();
  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressLoaded extends AddressState {
  final AddressModel? address;
  const AddressLoaded(this.address);
  @override
  List<Object?> get props => [address];
}
