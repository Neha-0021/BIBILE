import 'package:bible_app/services/config.dart';
import 'package:dio/dio.dart';

final dio = Dio();

class BookService {
  String baseUrl = ServiceConfig.baseUrl;

  Future<Response> getAllBooks() async {
    try {
      final response = await dio.get(
        "$baseUrl/api/user/get-all-books",
      );
      return response;
    } catch (err) {
      if (err is DioException) {
        return err.response!;
      }
      rethrow;
    }
  }
   
}
