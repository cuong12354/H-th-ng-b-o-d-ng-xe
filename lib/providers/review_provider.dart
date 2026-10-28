import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<dynamic> _reviews = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<dynamic> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchReviews() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get('/Review');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _reviews = response.data['data'];
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReview({
    required int appointmentId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await _apiService.dio.post('/Review', data: {
        'appointmentId': appointmentId,
        'rating': rating,
        'comment': comment
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        await fetchReviews();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
