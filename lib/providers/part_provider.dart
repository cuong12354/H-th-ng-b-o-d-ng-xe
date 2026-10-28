import 'package:flutter/material.dart';
import '../models/part_model.dart';
import '../services/api_service.dart';

class PartProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<PartModel> _parts = [];
  bool _isLoading = false;

  List<PartModel> get parts => _parts;
  List<PartModel> get spareParts => _parts.where((p) => p.isSparePart).toList();
  List<PartModel> get accessories => _parts.where((p) => p.isAccessory).toList();
  bool get isLoading => _isLoading;

  Future<void> fetchParts([String? query, String? category]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final queryParams = <String>[];
      if (query != null && query.isNotEmpty) {
        queryParams.add('search=${Uri.encodeComponent(query)}');
      }
      if (category != null && category.isNotEmpty) {
        queryParams.add('category=${Uri.encodeComponent(category)}');
      }
      final endpoint = queryParams.isNotEmpty
          ? '/Part?${queryParams.join('&')}'
          : '/Part';
      final response = await _apiService.dio.get(endpoint);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        _parts = data.map((json) => PartModel.fromJson(json)).toList();
      }
    } catch (e) {
      // handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPart(String name, String description, double price, int stockQuantity, [String category = 'SPARE_PART']) async {
    try {
      final response = await _apiService.dio.post('/Part', data: {
        'name': name,
        'description': description,
        'price': price,
        'stockQuantity': stockQuantity,
        'category': category,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        await fetchParts();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePart(int id, String name, String description, double price, int stockQuantity, [String? category]) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'description': description,
        'price': price,
        'stockQuantity': stockQuantity,
      };
      if (category != null && category.isNotEmpty) {
        data['category'] = category;
      }
      final response = await _apiService.dio.put('/Part/$id', data: data);

      if (response.statusCode == 200 && response.data['success'] == true) {
        await fetchParts();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePart(int id) async {
    try {
      final response = await _apiService.dio.delete('/Part/$id');
      if (response.statusCode == 200 && response.data['success'] == true) {
        await fetchParts();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
