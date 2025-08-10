import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bicaraku/core/network/api_constant.dart';

class DioClient {
  final Dio _dio;

  // Private constructor
  DioClient._()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    // Interceptor untuk logging dan menambahkan token otorisasi
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = GetStorage().read('token');
          if (token != null && token.toString().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('--> ${options.method.toUpperCase()} ${options.uri}');
          if (options.data != null) {
            print('Data: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('<-- ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('<-- Error: ${error.type} - ${error.message}');
          if (error.response != null) {
            print('Error Response: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Singleton instance untuk memastikan hanya ada satu object DioClient di seluruh aplikasi
  static final DioClient _instance = DioClient._();
  factory DioClient() => _instance;

  /// GET method
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST method
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// ✅ METHOD PUT DITAMBAHKAN
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// ✅ METHOD DELETE DITAMBAHKAN
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Method untuk menangani error dari Dio dengan lebih detail
  Exception _handleError(DioException e) {
    String errorMessage;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage =
            'Timeout Error: Koneksi ke server terputus. Cek koneksi internet atau alamat server.';
        break;
      case DioExceptionType.badResponse:
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage =
              "Error dari server (${e.response?.statusCode}): ${responseData['message']}";
        } else {
          errorMessage =
              "Error dari server (${e.response?.statusCode}): Terjadi kesalahan.";
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Permintaan ke server dibatalkan.';
        break;
      case DioExceptionType.connectionError:
        errorMessage =
            'Connection Error: Tidak bisa terhubung ke server. **PERIKSA ALAMAT IP/URL SERVER ANDA!**';
        break;
      default:
        errorMessage = 'Terjadi kesalahan tidak terduga.';
        break;
    }
    return Exception(errorMessage);
  }
}
