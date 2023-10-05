// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft_parameters.dart';

// **************************************************************************
// BorshSerializableGenerator
// **************************************************************************

mixin _$NftArguments {
  BigInt get id => throw UnimplementedError();
  String get name => throw UnimplementedError();
  String get symbol => throw UnimplementedError();
  String get uri => throw UnimplementedError();
  BigInt get price => throw UnimplementedError();
  BigInt get cant => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BU64().write(writer, id);
    const BString().write(writer, name);
    const BString().write(writer, symbol);
    const BString().write(writer, uri);
    const BU64().write(writer, price);
    const BU64().write(writer, cant);

    return writer.toArray();
  }
}

class _NftArguments extends NftArguments {
  _NftArguments({
    required this.id,
    required this.name,
    required this.symbol,
    required this.uri,
    required this.price,
    required this.cant,
  }) : super._();

  final BigInt id;
  final String name;
  final String symbol;
  final String uri;
  final BigInt price;
  final BigInt cant;
}

class BNftArguments implements BType<NftArguments> {
  const BNftArguments();

  @override
  void write(BinaryWriter writer, NftArguments value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  NftArguments read(BinaryReader reader) {
    return NftArguments(
      id: const BU64().read(reader),
      name: const BString().read(reader),
      symbol: const BString().read(reader),
      uri: const BString().read(reader),
      price: const BU64().read(reader),
      cant: const BU64().read(reader),
    );
  }
}

NftArguments _$NftArgumentsFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BNftArguments().read(reader);
}
