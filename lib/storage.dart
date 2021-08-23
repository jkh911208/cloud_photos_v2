import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = new FlutterSecureStorage();

Future<int> getCloudCreatedEpoch() async {
  final String? cloudCreatedEpoch =
      await storage.read(key: "cloudCreatedEpoch");
  if (cloudCreatedEpoch != null) {
    final int parsedInteger = int.parse(cloudCreatedEpoch);
    return parsedInteger;
  }
  return 0;
}

Future<void> writeCloudCreatedEpoch(int value) async {
  final int currentValue = await getCloudCreatedEpoch();
  if (value > currentValue) {
    await storage.write(key: "cloudCreatedEpoch", value: value.toString());
  }
}

Future<bool> getWifiOnly() async {
  final String? currentWifiOnly = await storage.read(key: "wifiOnly");
  if (currentWifiOnly != null) {
    if (currentWifiOnly == "true") {
      return true;
    }
    return false;
  }
  return true;
}

Future<void> setWifiOnly(bool value) async {
  await storage.write(key: "wifiOnly", value: value.toString());
}
