import 'package:audioplayers/audioplayers.dart';
import 'package:bible_app/services/books_chapters.dart';
import 'package:bible_app/utils/alert.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class BookState extends ChangeNotifier {
  final BookService service = BookService();
  AlertBundle alert = AlertBundle();

  List<dynamic> books = [];
  Map<String, dynamic> bookDetails = {};

  List<dynamic> chapter = [];
  List<dynamic> bookmark = [];
  String shareableLink = '';
  List<dynamic> texts = [];
  Map<String, dynamic> addedbookmark = {};
  

  Map<String, dynamic> data = {
    "deviceId": "",
    "fcmToken": "",
  };
  final AudioPlayer audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool _isLoading = false;
  bool isBookmarked = false;

  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  bool get isPlaying => _isPlaying;

  void play(String audioUrl, String bookId) async {
    if (_selectedBookId != bookId) {
      // Pause audio if playing in a different book
      await audioPlayer.pause();
      _isPlaying = false;
    }

    _isLoading = true;

    await audioPlayer.stop();
    await audioPlayer.play(UrlSource(audioUrl));
    _isLoading = false;

    _selectedBookId = bookId;
    setSelectedCellIndices(bookId, getSelectedCellIndex(bookId));
    notifyListeners();
  }

  String _selectedBookId = ''; // Add this line to store the selected book ID

  String get selectedBookId => _selectedBookId;

  void setSelectedBookId(String bookId) {
    _selectedBookId = bookId;
    notifyListeners();
  }

  bool get isBookMarked => _isBookMarked;

  void setBookMarked(bool value) {
    _isBookMarked = value;
    notifyListeners();
  }

  bool _isBookMarked = false;

  final Map<String, int> _selectedCellIndices = {};

  int getSelectedCellIndex(String bookId) {
    return _selectedCellIndices.containsKey(bookId)
        ? _selectedCellIndices[bookId]!
        : -1;
  }

  void setSelectedCellIndices(String bookId, int index) {
    _selectedCellIndices.clear();
    _selectedCellIndices[bookId] = index;
    notifyListeners();
  }

   void clearSelectedCellIndices() {
    _selectedCellIndices.clear();
    notifyListeners();
  }
 void stopPlaying() async {
    await audioPlayer.stop();
    _isPlaying = false;
    notifyListeners();
  }

  int? _selectedBookIndex;

  int? get selectedBookIndex => _selectedBookIndex;

  void setSelectedBookIndex(int index) {
    _selectedBookIndex = index;
    notifyListeners();
  }

  int getSelectedBookIndex() {
    return _selectedBookIndex ?? -1;
  }

  Duration get duration => _duration;

  Duration get position => _position;

  void setDuration(Duration duration) {
    _duration = duration;
    notifyListeners();
  }

  void setPosition(Duration position) {
    _position = position;
    notifyListeners();
  }

  void playing(bool value) {
    _isPlaying = value;
    notifyListeners();
  }



  String? getSelectedBookTitle() {
    // Assuming you have a property named 'selectedBookId' in your class
    String? selectedBookId = this.selectedBookId;

    Map<String, dynamic>? selectedBook = books.firstWhere(
        (book) => book['_id'] == selectedBookId,
        orElse: () => null);

    // Return the title if the book is found, otherwise return null or a default value
    return selectedBook != null ? selectedBook['title'] : null;
  }

  void setIsPlaying(PlayerState state) {
    _isPlaying = state == PlayerState.playing;
  }

  String _selectedBookType =
      ''; // Add this line to store the selected book type

  String get selectedBookType => _selectedBookType;

  void setSelectedBookType(String type) {
    _selectedBookType = type;
    notifyListeners();
  }

  String getSelectedBookType() {
    return _selectedBookType;
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> getAllBook() async {
    try {
      Response response = await service.getAllBooks();

      books = response.data["books"];
      if (kDebugMode) {
        print('Response from API: ${response.data}');
      }

      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching books: $error');
      }
    }
  }

  Future<void> getBooksByType(String type) async {
    try {
      Response response = await service.getBooksByType(type);

      books = response.data["books"];

      if (kDebugMode) {
        print('Response from API: ${response.data}');
      }

      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching books: $error');
      }
    }
  }

  Future<void> getTextbystyle(String style) async {
    try {
      Response response = await service.getTextbystyle(style);

      texts = response.data["text"];

      if (kDebugMode) {
        print('Response from API: ${response.data}');
      }

      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching books: $error');
      }
    }
  }

  Future<void> getChapterBybookId(String bookId) async {
    try {
      Response response = await service.getChapterByBookId(bookId);

      Map<String, dynamic> responseData =
          Map<String, dynamic>.from(response.data);
      if (kDebugMode) {
        print('Response: $responseData');
      }

      if (responseData.containsKey("book")) {
        bookDetails = Map<String, dynamic>.from(responseData["book"]);
        chapter = responseData["book"]["chapters"];
      } else {
        chapter = [];
      }

      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching chapters: $error');
      }

      chapter = [];
    }
  }

  addBookmark(String chapterId, String deviceId, context) async {
    try {
      Response response = await service.addBookmark(chapterId, deviceId);

      if (response.statusCode == 200) {
        setBookMarked(true);
        alert.SnackBarNotify(context, "add successfully the audio in bookmark");
      } else {
        alert.SnackBarNotify(
            context, "book mark alredy added for this chapter");
      }

      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error adding bookmark: $error');
      }
    }
  }

  getBookMarkbydeviceId(
    String deviceId,
  ) async {
    try {
      Response response = await service.getBookMarkbydeviceId(deviceId);

      bookmark = response.data["bookmark"];
      if (kDebugMode) {
        print('Response  API: ${response.data}');
      }
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching bookmark: $error');
      }
    }
  }

  getBookMarkbychapterIddeviceId(String chapterId, String deviceId) async {
    try {
      Response response =
          await service.getBookMarkbyChapterIdandDeviceId(chapterId, deviceId);

      if (response.statusCode == 200) {
        addedbookmark = response.data["bookmark"];
        setBookMarked(true);
      } else {
        if (response.statusCode == 400) {
          setBookMarked(false);
        }
      }

     
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching bychapter: $error');
      }
    }
  }

  shareAppLink(context) async {
    try {
      final response = await service.shareAppLink();

      if (response.statusCode == 200) {
        alert.SnackBarNotify(context, "add successfully share link");
      } else {
        alert.SnackBarNotify(context, "unable to add");
      }
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error sharing app link: $error');
      }
    }
  }

  getShareLinkbyPlatform(String platform) async {
    try {
      Response response = await service.getShareLink(platform);

      Map<String, dynamic> responseData = response.data;

      if (kDebugMode) {
        print('share app link: $responseData');
      }
      shareableLink = responseData["shareableLink"];
    
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching bookmark: $error');
      }
    }
  }

  removeBookmarkById(String bookmarkId, context) async {
    try {
      final response = await service.removeBookmark(bookmarkId);
      bookmark.removeWhere((bookmark) => bookmark["_id"] == bookmarkId);
      if (response.statusCode == 200) {
        alert.SnackBarNotify(context, "remove sucssefully this bookmark");
      } else {
        alert.SnackBarNotify(context, "unable to remove this bookmark");
      }
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error sharing app link: $error');
      }
    }
  }

  Future<dynamic> saveToken(String userDevice, String fcmToken) async {
    Response response = await service.saveFcmToken(userDevice, fcmToken);
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("save successfully");
      }
    }
    return {
      "code": response.statusCode,
      "message": response.data["message"],
    };
  }
}