import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import '../models/homeowner_model.dart';
import '../core/services/logger_service.dart';
import '../core/utils/api_response.dart';
import 'database_provider.dart';

class ReviewProvider with ChangeNotifier {
  final DatabaseProvider _databaseProvider;
  bool _loading = false;
  String? _error;
  List<Review> _reviews = [];

  ReviewProvider(this._databaseProvider);

  // Getters
  bool get loading => _loading;
  String? get error => _error;
  List<Review> get reviews => _reviews;

  Future<void> loadReviews({required String revieweeId}) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      _reviews = await _databaseProvider.getReviewsForProfessional(revieweeId);

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = 'Failed to load reviews: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> respondToReview(String reviewId, String response) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _databaseProvider.client
          .from('reviews')
          .update({'response': response}).eq('id', reviewId);

      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        _reviews[index] = _reviews[index].copyWith(response: response);
      }

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = 'Failed to respond to review: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateResponse(String reviewId, String response) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _databaseProvider.client
          .from('reviews')
          .update({'response': response}).eq('id', reviewId);

      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        _reviews[index] = _reviews[index].copyWith(response: response);
      }

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = 'Failed to update response: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<int, int>> getRatingDistribution(String userId) async {
    try {
      final reviews = await _databaseProvider.getReviewsForProfessional(userId);
      final distribution = <int, int>{};

      // Initialize all ratings from 1 to 5 with 0 count
      for (var i = 1; i <= 5; i++) {
        distribution[i] = 0;
      }

      // Count reviews for each rating
      for (final review in reviews) {
        final rating = review.rating.round();
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      LoggerService.error('Failed to get rating distribution', e);
      rethrow;
    }
  }

  Future<ApiResponse<List<Review>>> loadProfessionalReviews(
      String professionalId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      _reviews = await _databaseProvider.getProfessionalReviews(professionalId);

      _loading = false;
      notifyListeners();
      return ApiResponse.success(_reviews);
    } catch (e) {
      _loading = false;
      _error = 'Failed to load reviews: $e';
      notifyListeners();
      return ApiResponse.error(_error!);
    }
  }

  Future<ApiResponse<Review>> createReview({
    required String professionalId,
    required String homeownerId,
    required String jobId,
    required double rating,
    required String comment,
    required Homeowner homeowner,
    List<String> photos = const [],
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final now = DateTime.now();
      final review = Review(
        id: now.millisecondsSinceEpoch
            .toString(), // This will be replaced by the database
        professionalId: professionalId,
        homeownerId: homeownerId,
        jobId: jobId,
        rating: rating,
        comment: comment,
        photos: photos,
        createdAt: now,
        updatedAt: now,
        homeowner: homeowner,
      );

      // Add review to database
      final response = await _databaseProvider.client
          .from('reviews')
          .insert(review.toJson())
          .select()
          .single();

      final newReview = Review.fromJson(response);
      _reviews.add(newReview);

      // Update professional's rating
      final allReviews =
          await _databaseProvider.getProfessionalReviews(professionalId);
      final averageRating =
          allReviews.fold<double>(0, (sum, review) => sum + review.rating) /
              allReviews.length;
      await _databaseProvider.updateProfessionalRating(
          professionalId, averageRating);

      _loading = false;
      notifyListeners();
      return ApiResponse.success(newReview);
    } catch (e) {
      LoggerService.error('Failed to create review', e);
      _loading = false;
      _error = 'Failed to create review: $e';
      notifyListeners();
      return ApiResponse.error(_error!);
    }
  }

  Future<ApiResponse<void>> deleteReview(
      String reviewId, String professionalId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _databaseProvider.client
          .from('reviews')
          .delete()
          .eq('id', reviewId);
      _reviews.removeWhere((review) => review.id == reviewId);

      // Update professional's rating
      final allReviews =
          await _databaseProvider.getProfessionalReviews(professionalId);
      if (allReviews.isNotEmpty) {
        final averageRating =
            allReviews.fold<double>(0, (sum, review) => sum + review.rating) /
                allReviews.length;
        await _databaseProvider.updateProfessionalRating(
            professionalId, averageRating);
      }

      _loading = false;
      notifyListeners();
      return ApiResponse.success(null);
    } catch (e) {
      LoggerService.error('Failed to delete review', e);
      _loading = false;
      _error = 'Failed to delete review: $e';
      notifyListeners();
      return ApiResponse.error(_error!);
    }
  }

  Future<ApiResponse<Review>> updateReview({
    required String reviewId,
    required String professionalId,
    double? rating,
    String? comment,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final Map<String, dynamic> updates = {};
      if (rating != null) updates['rating'] = rating;
      if (comment != null) updates['comment'] = comment;
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _databaseProvider.client
          .from('reviews')
          .update(updates)
          .eq('id', reviewId)
          .select()
          .single();

      final updatedReview = Review.fromJson(response);
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        _reviews[index] = updatedReview;
      }

      // Update professional's rating if rating was changed
      if (rating != null) {
        final allReviews =
            await _databaseProvider.getProfessionalReviews(professionalId);
        final averageRating =
            allReviews.fold<double>(0, (sum, review) => sum + review.rating) /
                allReviews.length;
        await _databaseProvider.updateProfessionalRating(
            professionalId, averageRating);
      }

      _loading = false;
      notifyListeners();
      return ApiResponse.success(updatedReview);
    } catch (e) {
      LoggerService.error('Failed to update review', e);
      _loading = false;
      _error = 'Failed to update review: $e';
      notifyListeners();
      return ApiResponse.error(_error!);
    }
  }
}
