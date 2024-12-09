import 'dart:convert';

import 'package:dio/dio.dart';
//import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:get/get.dart' as get_base;
//import 'package:im_flutter/common/routers/names.dart';
import 'package:im_flutter/global.dart';
import 'index.dart';

const String methodPost = 'post';
const String methodGet = 'get';

// 业务成功code
const codeResponseSuccess = 0;
const codeErrorUnknown = -1;

class Resource {
  int code;
  String? message;
  dynamic data;

  Resource.success(this.data, {this.code = codeResponseSuccess});

  Resource.error(this.message, this.code);

  bool isSuccess() {
    return code == codeResponseSuccess;
  }
}

class HttpUtil {
  static Future<Resource> get(String path,
      {Map<String, dynamic>? params,
      Options? options,
      CancelToken? cancelToken,
      bool refresh = false,
      String? cacheKey,
      bool noCache = false,
      bool cacheDisk = true,
      ProgressCallback? onReceiveProgress}) async {
    return _sendRequest(
        methodGet,
        Global.SERVER_API_URL + path,
        params,
        options,
        cancelToken,
        onReceiveProgress,
        refresh,
        cacheKey,
        noCache,
        cacheDisk);
  }

  static Future<Resource> post(String path,
      {Map<String, dynamic>? params,
      Options? options,
      CancelToken? cancelToken,
      bool refresh = false,
      String? cacheKey,
      bool noCache = false,
      bool cacheDisk = true,
      ProgressCallback? onReceiveProgress}) async {
    return _sendRequest(
        methodPost,
        Global.SERVER_API_URL + path,
        params,
        options,
        cancelToken,
        onReceiveProgress,
        refresh,
        cacheKey,
        noCache,
        cacheDisk);
  }

  static Future<Resource> upload(String path,
      {required String filePath,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onReceiveProgress}) async {
    FormData formData = FormData.fromMap({
      "upload_file": await MultipartFile.fromFile(filePath),
      "platType": "m"
    });
    var dio = DioManager().dio;
    try {
      Response rsp =
          await dio.post(Global.SERVER_API_URL + path, data: formData);
      if (rsp == null) return Resource.error('未知错误1', codeErrorUnknown);

      return _handleResponse(rsp);
    } catch (err) {
      return Resource.error(_handleException(err), codeErrorUnknown);
    }
  }

  static Future<Resource> _sendRequest(
    String method,
    String path,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool refresh,
    String? cacheKey,
    bool noCache,
    bool cacheDisk,
  ) async {
    var dio = DioManager().dio;
    try {
      Response? rsp;
      Options requestOptions = options ?? Options();
      requestOptions = requestOptions.copyWith(
        extra: {
          "refresh": refresh,
          "noCache": noCache,
          "cacheKey": cacheKey,
          "cacheDisk": cacheDisk,
        },
      );
      if (method == methodGet) {
        rsp = await dio.get(path,
            queryParameters: params, options: requestOptions);
      } else if (method == methodPost) {
        var p = jsonEncode(params);
        rsp = await dio.post(path, data: params);
      }
      if (rsp == null) {
        return Resource.error('未知错误1', codeErrorUnknown);
      }
      return _handleResponse(rsp);
    } on DioError catch (err) {
      if (err.response?.statusCode == 401) {
        get_base.Get.toNamed(RouteNames.systemLogin);
      }

      return Resource.error(_handleException(err), codeErrorUnknown);
    }
  }

  static Resource _handleResponse(Response response) {
    if (_isSuccess(response.statusCode)) {
      var data = response.data['data'];
      var status = response.data['code'];
      String? msg = response.data['message'];
      if (status == codeResponseSuccess) {
        //处理新token
        if(response.headers.value('New-Access-Token')!=null)
          UserService.to.token = response.headers.value('New-Access-Token')!;
        if(response.headers.value('New-Login-Id')!=null)
          UserService.to.loginId = response.headers.value('New-Login-Id')!;

        return Resource.success(data);
      } else {
        if (status == 1000) {
          // 添加跳转控制
/*          UserService.to.logout();

          var routePath = Get.currentRoute;
          if (routePath == RouterTable.main) {
            Get.toNamed(RouterTable.openAccount);
          } else {
            Get.offNamed(RouterTable.login);
          }
          print(routePath);
          */
        } else if (status == 401) {}
        return Resource.error(msg, status);
      }
    } else {
      if (response.statusCode == 401) {
        print('401');
      }
      return Resource.error('未知错误2', codeErrorUnknown);
    }
  }

  static bool _isSuccess(int? statusCode) {
    return (statusCode != null && statusCode >= 200 && statusCode < 300);
  }

  static String _handleException(ex) {
    if (ex is DioError) {
      switch (ex.type) {
        case DioErrorType.connectionTimeout:
        case DioErrorType.sendTimeout:
        case DioErrorType.receiveTimeout:
          return '网络连接超时';
        case DioErrorType.unknown:
          return '未知错误3';
        case DioErrorType.badResponse:
          int? statusCode = ex.response?.statusCode;
          switch (statusCode) {
            case 400:
              return '请求语法错误';
            case 401:
//              Get.toNamed(RouteNames.systemLogin);
              return '登录失效';
            case 403:
              return '服务器拒绝执行';
            case 404:
              return '请求资源不存在';
            case 405:
              return '请求方法被禁止';
            case 500:
              return '服务器内部错误';
            case 502:
              return '无效请求';
            case 503:
              return '服务器异常';
            default:
              return '未知错误4';
          }
        default:
          return '未知错误5';
      }
    } else {
      return '未知错误6';
    }
  }
}
