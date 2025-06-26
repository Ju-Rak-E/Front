import 'package:dio/dio.dart';
import 'dio_interceptor.dart';

final Dio dio = Dio();

void setupDio() {
  dio.interceptors.clear();
  dio.interceptors.add(DioInterceptor(dio));
}
