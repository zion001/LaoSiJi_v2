import 'package:flutter/material.dart';

import 'package:mqtt_client/mqtt_client.dart';

class ConnectionStateModel extends ChangeNotifier {
  ConnectionStateModel(this._connectionState);

  MqttConnectionState _connectionState = MqttConnectionState.disconnected;
  MqttConnectionState get connectionState => _connectionState;
  set connectionState(MqttConnectionState connectionState) {
    _connectionState = connectionState;
    notifyListeners();
  }

  String getConnectionString() {
    String connectionString = '';
    switch (_connectionState) {
      case MqttConnectionState.disconnected:
        connectionString = "未连接";
        break;
      case MqttConnectionState.connected:
        connectionString = "已连接";
        break;
      case MqttConnectionState.connecting:
        connectionString = "正在连接...";
        break;
      case MqttConnectionState.disconnecting:
        connectionString = "正在断开...";
        break;
      case MqttConnectionState.faulted:
        connectionString = "连接失败";
        break;
    }
    return connectionString;
  }
}
