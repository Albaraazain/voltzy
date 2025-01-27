import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/category_model.dart';

class ServiceProvider extends ChangeNotifier {
  final SupabaseClient _client = SupabaseConfig.client;
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client
          .from('service_categories')
          .select('*, services(*)')
          .filter('deleted_at', 'is', null)
          .order('name');

      _categories =
          response.map<Category>((json) => Category.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
