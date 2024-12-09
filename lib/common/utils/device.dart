import 'package:im_flutter/common/index.dart';
import 'package:uuid/uuid.dart';

class DeviceInfo {
  /// UUID
  static String get uuid {
    var uuid = Storage().getString(Constants.storageUUID);
    if (uuid.isNotEmpty) {
      return uuid;
    }
    uuid = const Uuid().v1();
    Storage().setString(Constants.storageUUID, uuid);
    return uuid;
  }
}
