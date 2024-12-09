import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:im_flutter/common/index.dart';

class DioManager {
  static const connectTimeout = 5; //连接服务器超时时间，单位是秒.
  static const receiveTimeout = 5; //响应流上前后两次接受到数据的间隔，单位为秒。
  static final options = BaseOptions(
    connectTimeout: const Duration(seconds: connectTimeout),
    receiveTimeout: const Duration(seconds: receiveTimeout),
  );

  static final DioManager _instance = DioManager._internal();

  factory DioManager() => _instance;

  DioManager._internal() {
    getDioInstance();
  }

  Dio dio = Dio();

  void getDioInstance() {
    //dio = Dio()..interceptors.add(DioCacheInterceptor(options: options));

    dio = Dio(options);
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (kIsWeb) {
        options.headers['x-device'] = 'Web';
        options.headers['x-device-type'] = 1005;
        options.headers['x-device-id'] = DeviceInfo.uuid;
      } else if (Platform.isIOS) {
        options.headers['x-device'] = 'iOS';
        options.headers['x-device-type'] = 1001;
        options.headers['x-device-id'] = DeviceInfo.uuid;
      } else if (Platform.isAndroid) {
        options.headers['x-device'] = 'Android';
        options.headers['x-device-type'] = 1002;
        options.headers['x-device-id'] = DeviceInfo.uuid;
      } else if (Platform.isWindows) {
        options.headers['x-device'] = 'Windows';
        options.headers['x-device-type'] = 1003;
        options.headers['x-device-id'] = DeviceInfo.uuid;
      } else if (Platform.isMacOS) {
        options.headers['x-device'] = 'OSX';
        options.headers['x-device-type'] = 1004;
        options.headers['x-device-id'] = DeviceInfo.uuid;
      } else if (Platform.isLinux) {
        options.headers['x-device'] = 'Linux';
        options.headers['x-device-type'] = 1007;
        options.headers['x-device-id'] = DeviceInfo.uuid;
      }
      // http header 头加入 Authorization
      if (UserService.to.hasToken) {
        options.headers['Authorization'] = UserService.to.token;
      }

      return handler.next(options);
    }, onResponse: (response, handler) {
      handler.next(response);
    }, onError: (DioError e, handler) {
      return handler.next(e);
    }));
  }
}
