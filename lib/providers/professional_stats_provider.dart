import 'package:flutter/foundation.dart';
import '../core/services/logger_service.dart';
import '../core/utils/api_response.dart';
import '../models/professional_stats.dart';
import 'database_provider.dart';

class ProfessionalStatsProvider with ChangeNotifier {
  final DatabaseProvider _databaseProvider;
  bool _loading = false;
  String? _error;
  ProfessionalStats _stats = ProfessionalStats.initial();

  ProfessionalStatsProvider(this._databaseProvider);

  // Getters
  bool get loading => _loading;
  String? get error => _error;
  ProfessionalStats get stats => _stats;

  Future<ApiResponse<ProfessionalStats>> loadStats(
      String professionalId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      // Get all jobs for the professional
      final jobs =
          await _databaseProvider.getJobsForProfessional(professionalId);

      // Calculate statistics
      final totalJobs = jobs.length;
      final completedJobs =
          jobs.where((job) => job.status == 'completed').length;
      final cancelledJobs =
          jobs.where((job) => job.status == 'cancelled').length;

      // Calculate jobs by status
      final jobsByStatus = <String, int>{};
      for (final job in jobs) {
        jobsByStatus[job.status] = (jobsByStatus[job.status] ?? 0) + 1;
      }

      // Calculate earnings by month
      final earningsByMonth = <String, double>{};
      for (final job in jobs) {
        if (job.status == 'completed') {
          final monthKey =
              '${job.date.year}-${job.date.month.toString().padLeft(2, '0')}';
          earningsByMonth[monthKey] =
              (earningsByMonth[monthKey] ?? 0) + job.price;
        }
      }

      // Get professional's rating
      final reviews =
          await _databaseProvider.getProfessionalReviews(professionalId);
      final averageRating = reviews.isEmpty
          ? 0.0
          : reviews.fold<double>(0, (sum, review) => sum + review.rating) /
              reviews.length;

      // Calculate total earnings
      final totalEarnings = jobs
          .where((job) => job.status == 'completed')
          .fold<double>(0, (sum, job) => sum + job.price);

      // Calculate weekly earnings
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weeklyEarnings = jobs
          .where(
              (job) => job.status == 'completed' && job.date.isAfter(weekStart))
          .fold<double>(0, (sum, job) => sum + job.price);

      _stats = ProfessionalStats(
        totalJobs: totalJobs,
        completedJobs: completedJobs,
        cancelledJobs: cancelledJobs,
        averageRating: averageRating,
        totalEarnings: totalEarnings,
        weeklyEarnings: weeklyEarnings,
        jobsByStatus: jobsByStatus,
        earningsByMonth: earningsByMonth,
      );

      _loading = false;
      notifyListeners();
      return ApiResponse.success(_stats);
    } catch (e) {
      LoggerService.error('Failed to load professional stats', e);
      _loading = false;
      _error = 'Failed to load professional stats: $e';
      notifyListeners();
      return ApiResponse.error(_error!);
    }
  }

  Future<ApiResponse<Map<String, double>>> getEarningsTrend(
    String professionalId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final jobs =
          await _databaseProvider.getJobsForProfessional(professionalId);
      final earningsByDate = <String, double>{};

      for (final job in jobs) {
        if (job.status == 'completed' &&
            (startDate == null || job.date.isAfter(startDate)) &&
            (endDate == null || job.date.isBefore(endDate))) {
          final dateKey = job.date.toString().split(' ')[0]; // YYYY-MM-DD
          earningsByDate[dateKey] = (earningsByDate[dateKey] ?? 0) + job.price;
        }
      }

      _loading = false;
      notifyListeners();
      return ApiResponse.success(earningsByDate);
    } catch (e) {
      LoggerService.error('Failed to get earnings trend', e);
      _loading = false;
      _error = 'Failed to get earnings trend: $e';
      notifyListeners();
      return ApiResponse.error(_error!);
    }
  }

  Future<ApiResponse<Map<String, int>>> getJobsDistribution(
      String professionalId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final jobs =
          await _databaseProvider.getJobsForProfessional(professionalId);
      final distribution = <String, int>{};

      for (final job in jobs) {
        distribution[job.service.name] =
            (distribution[job.service.name] ?? 0) + 1;
      }

      _loading = false;
      notifyListeners();
      return ApiResponse.success(distribution);
    } catch (e) {
      LoggerService.error('Failed to get jobs distribution', e);
      _loading = false;
      _error = 'Failed to get jobs distribution: $e';
      notifyListeners();
      return ApiResponse.error(_error!);
    }
  }
}
