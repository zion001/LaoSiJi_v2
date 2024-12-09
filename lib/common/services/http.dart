import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:im_flutter/common/services/user_service.dart';
import 'package:im_flutter/global.dart';
import '../index.dart';

class HttpService extends GetxService {
  static HttpService get to => Get.find();

  late final Dio _dio;

  @override
  void onInit() {
    super.onInit();

    var options = BaseOptions(
      baseUrl: Global.SERVER_API_URL,
      connectTimeout: const Duration(seconds: 10), //10秒
      receiveTimeout: const Duration(seconds: 10), //5秒
      headers: {},
      contentType: 'application/json; charset=utf-8',
      responseType: ResponseType.json,
    );

    _dio = Dio(options);
    // 拦截器
    _dio.interceptors.add(CustomInterceptors());
  }

  // GET
  Future<Response> get(
    String url, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    Options requestOptions = options ?? Options();
    Response response = await _dio.get(
      url,
      queryParameters: params,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    return response;
  }

  // POST
  Future<Response> post(
    String url, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var requestOptions = options ?? Options();
    Response response = await _dio.post(
      url,
      data: data ?? {},
      options: requestOptions,
      cancelToken: cancelToken,
    );
    return response;
  }
}

class CustomInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('REQUEST[${options.method}] => PATH: ${options.path}');
    }

    options.headers['x-device'] = 'iOS';
    options.headers['x-device-id'] = DeviceInfo.uuid;
    // http header 头加入 Authorization
    if (UserService.to.hasToken) {
      options.headers['Authorization'] = UserService.to.token;
    }

    return handler.next(options);
    // 如果你想完成请求并返回一些自定义数据，你可以resolve一个Response对象 `handler.resolve(response)`。
    // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义response.
    //
    // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象,如`handler.reject(error)`，
    // 这样请求将被中止并触发异常，上层catchError会被调用。
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print(
          'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    }
    // 200 请求成功, 201 添加成功
    if (response.statusCode != 200 && response.statusCode != 201) {
      handler.reject(
        DioError(
          requestOptions: response.requestOptions,
          response: response,
          type: DioErrorType.badResponse,
        ),
        true,
      );
    } else {
      handler.next(response);
    }
  }

  @override
  void onError(
    DioError err,
    ErrorInterceptorHandler handler,
  ) {
    final exception = HttpException(err.message ?? "error message");
    switch (err.type) {
      case DioErrorType.badResponse:
        {
          //服务端自定义错误体处理
          final response = err.response;
          final errorMessage = ErrorMessageModel.fromJson(response?.data);
          switch (errorMessage.statusCode) {
            case 401:
              _errorNoAuthLogout();
              break;
            default:
              break;
          }
          break;
        }
      case DioErrorType.connectionTimeout:
        break;
      case DioErrorType.connectionError:
        break;
      default:
        break;
    }
    var error = DioError(error: exception, requestOptions: RequestOptions());
    //err.error = exception;
    handler.next(error);
  }

  // 退出并重新登录
  Future<void> _errorNoAuthLogout() async {
    if (kDebugMode) {
      print("需要退出并重新登录");
    }
//    await UserService.to.logout();
//    Get.toNamed(RouteNames.systemLogin);
  }
}
