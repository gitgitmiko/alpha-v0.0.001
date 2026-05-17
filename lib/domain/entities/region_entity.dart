import 'package:equatable/equatable.dart';

class RegionEntity extends Equatable {
  const RegionEntity({
    required this.market,
    required this.locale,
    required this.language,
    required this.name,
    required this.currencyCode,
    required this.flagEmoji,
  });

  final String market;
  final String locale;
  final String language;
  final String name;
  final String currencyCode;
  final String flagEmoji;

  @override
  List<Object?> get props =>
      [market, locale, language, name, currencyCode, flagEmoji];
}
