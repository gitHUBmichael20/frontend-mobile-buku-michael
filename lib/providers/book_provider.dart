import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:front_end_mobile/models/book_model.dart';

class BookProvider with ChangeNotifier {
  List<Book> _books = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchBooks() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('http://192.168.168.1:8000/index'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _books = data.map((json) => Book.fromJson(json)).toList();
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to load data: ${response.statusCode}';
        if (kDebugMode) print('API Error: ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      if (kDebugMode) print('Fetch Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
