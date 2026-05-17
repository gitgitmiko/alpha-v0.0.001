import 'package:hive/hive.dart';

class CurrencyRateModel extends HiveObject {
  CurrencyRateModel({
    required this.from,
    required this.to,
    required this.rate,
    required this.updatedAt,
  });

  String from;
  String to;
  double rate;
  DateTime updatedAt;

  Map<String, dynamic> toMap() => {
        'from': from,
        'to': to,
        'rate': rate,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory CurrencyRateModel.fromMap(Map<dynamic, dynamic> map) =>
      CurrencyRateModel(
        from: map['from'] as String,
        to: map['to'] as String,
        rate: (map['rate'] as num).toDouble(),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );
}

class CurrencyRateModelAdapter extends TypeAdapter<CurrencyRateModel> {
  @override
  final int typeId = 5;

  @override
  CurrencyRateModel read(BinaryReader reader) =>
      CurrencyRateModel.fromMap(Map<dynamic, dynamic>.from(reader.readMap()));

  @override
  void write(BinaryWriter writer, CurrencyRateModel obj) {
    writer.writeMap(obj.toMap());
  }
}
