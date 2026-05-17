import 'package:workmanager/workmanager.dart';

const _uniqueName = 'xbox_price_sync';
const _taskName = 'priceSyncTask';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Scheduled local sync — full sync runs via PriceTrackerService in foreground
    return true;
  });
}

class PriceSyncWorker {
  static Future<void> register() async {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      _uniqueName,
      _taskName,
      frequency: const Duration(hours: 6),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
