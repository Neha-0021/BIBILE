import 'dart:io';

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

  Future<Response> getBooksByType(String type) async {
    try {
      final response = await dio.get(
        "$baseUrl/api/user/get-book-by-type/$type",
      );
      return response;
    } catch (err) {
      
      if (err is  DioException) {
        return err.response!;
      }
      rethrow;
    }
  }

  Future<Response> getChapterByBookId(String bookId) async {
    try {
      final response = await dio.get(
        "$baseUrl/api/user/get-chapter-by-bookId/$bookId",
      );
      return response;
    } catch (err) {
      if (err is DioException) {
        return err.response!;
      }
      rethrow;
    }
  }

 Future<Response> addBookmark(String chapterId, String deviceId) async {
    try {
      final response = await dio.post(
        "$baseUrl/api/bookmark/add-bookmark",
        data: {
          "chapterId": chapterId,
          "device": deviceId,
        },
      );
      return response;
    } catch (error) {
    
      if (error is  DioException) {
        return error.response!;
      }
      rethrow;
    }
  }

   Future<Response> getBookMarkbydeviceId(String devicedId) async {
    try {
      final response = await dio.get(
        "$baseUrl/api/bookmark/get-bookmark-by-device/$devicedId",
      );
      return response;
    } catch (err) {
      if (err is DioException) {
        return err.response!;
      }
      rethrow;
    }
  }

  Future<Response> getBookMarkbyChapterIdandDeviceId(String chapterId , String deviceId)  async {
    try {
      final response = await dio.get(
        "$baseUrl/api/bookmark/get-bookmark-by-chapterId/$chapterId/$deviceId",
      );
      return response;
    } catch (err) {
      if (err is DioException) {
        return err.response!;
      }
      rethrow;
    }
  }

  Future<Response> shareAppLink() async {
    try {
      final response = await dio.post(
        "$baseUrl/api/admin/share-link",
        data: {
          "platform": Platform.isAndroid ? "android" : "ios",
        },
      );
      return response;
    } catch (error) {
      if (error is  DioException) {
        return error.response!;
      }
      rethrow;
    }
  }

    Future<Response> getShareLink(String platform) async {
    try {
      final response = await dio.get(
        "$baseUrl/api/admin/share-link/$platform",
      );
      return response;
    } catch (err) {
      if (err is DioException) {
        return err.response!;
      }
      rethrow;
    }
  }

  Future<Response> removeBookmark(String bookmarkId)  async {
    try {
      final response = await dio.delete(
        "$baseUrl/api/bookmark/remove-bookmark/$bookmarkId",
      );
      return response;
    } catch (err) {
      if (err is  DioException) {
        return err.response!;
      }
      rethrow;
    }
  }
Future<Response> saveFcmToken(String userDevice, String fcmToken) async {
    try {
      final response = await dio.post(
        "$baseUrl/api/user/save-user-device",
        data: {
          "userDevice": userDevice,
          "fcmToken": fcmToken,
        },
      );
      return response;
    } catch (error) {
      if (error is  DioException) {
        return error.response!;
      }
      rethrow;
    }
  }

  Future<Response> getTextbystyle(String style) async {
    try {
      final response = await dio.get(
        "$baseUrl/api/admin/get-text-by-style/$style",
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
