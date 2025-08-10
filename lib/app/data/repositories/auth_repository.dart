import 'package:bicaraku/app/data/controllers/total_points_controller.dart';
import 'package:bicaraku/app/data/controllers/user_controller.dart';
import 'package:bicaraku/app/data/models/user_model.dart';
import 'package:bicaraku/core/network/api_constant.dart';
import 'package:bicaraku/core/network/dio_client.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class AuthRepository {
  final DioClient _dioClient;

  AuthRepository() : _dioClient = Get.find<DioClient>();

  /// Login dengan email, password, dan deviceInfo
  Future<Map<String, dynamic>> login(
    String email,
    String password,
    Map<String, dynamic> deviceInfo,
  ) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password, 'device_info': deviceInfo},
      );

      // Jika sukses, update UserController & TotalPoints
      if (response.data['user'] != null) {
        final user = UserModel.fromJson(response.data['user']);
        Get.find<UserController>().setUser(user);
        Get.put(TotalPointsController()).loadTotalPoints();
      }

      return _handleResponse(response);
    } on dio.DioException catch (e) {
      print("Login Error: ${e.response?.data} | ${e.message}");
      throw _handleError(e);
    }
  }

  /// Register pengguna
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.register,
        data: {'name': name, 'email': email, 'password': password},
      );
      return _handleResponse(response);
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Login dengan Google + device info
  Future<Map<String, dynamic>> loginWithGoogle(
    String idToken,
    Map<String, dynamic> deviceInfo,
  ) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.googleLogin,
        data: {'idToken': idToken, 'device_info': deviceInfo},
      );

      if (response.data['user'] != null) {
        final user = UserModel.fromJson(response.data['user']);
        Get.find<UserController>().setUser(user);
        Get.put(TotalPointsController()).loadTotalPoints();
      }

      return _handleResponse(response);
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cek status code dan return data
  Map<String, dynamic> _handleResponse(dio.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      throw dio.DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: response.data['message'] ?? 'Unknown error occurred',
      );
    }
  }

  /// Tangani kesalahan network
  String _handleError(dio.DioException error) {
    final message =
        error.response?.data?['message'] ??
        error.message ??
        'Terjadi kesalahan yang tidak diketahui';
    final statusCode = error.response?.statusCode ?? 500;

    switch (statusCode) {
      case 400:
        return 'Permintaan tidak valid: $message';
      case 401:
        return 'Autentikasi gagal: $message';
      case 404:
        return 'Endpoint tidak ditemukan: $message';
      default:
        return 'Error $statusCode: $message';
    }
  }
}
