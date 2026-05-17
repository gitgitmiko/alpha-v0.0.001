import 'package:flutter_test/flutter_test.dart';
import 'package:xbox_region_store_browser/core/constants/app_constants.dart';

void main() {
  test('app constants are defined', () {
    expect(AppConstants.appName, isNotEmpty);
    expect(AppConstants.freeSearchLimit, 3);
  });
}
