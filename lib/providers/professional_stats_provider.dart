import 'package:flutter/foundation.dart';
import '../core/services/logger_service.dart';
import '../core/utils/api_response.dart';
import '../models/professional_stats.dart';
import 'database_provider.dart';
import '../models/job_model.dart';

class ProfessionalStatsProvider with ChangeNotifier {
  final DatabaseProvider _databaseProvider;
  bool _loading = false;
  String? _error;
  ProfessionalStats _stats = ProfessionalStats.initial();
  int _totalJobs = 0;
  int _completedJobs = 0;
  int _cancelledJobs = 0;
  double _totalEarnings = 0;
  int _weeklyCompletedJobs = 0;
  double _weeklyEarnings = 0;
  int _monthlyCompletedJobs = 0;
  double _monthlyEarnings = 0;

  ProfessionalStatsProvider(this._databaseProvider);

  // Getters
  bool get loading => _loading;
  String? get error => _error;
  ProfessionalStats get stats => _stats;
  int get totalJobs => _totalJobs;
  int get completedJobs => _completedJobs;
  int get cancelledJobs => _cancelledJobs;
  double get totalEarnings => _totalEarnings;
  int get weeklyCompletedJobs => _weeklyCompletedJobs;
  double get weeklyEarnings => _weeklyEarnings;
  int get monthlyCompletedJobs => _monthlyCompletedJobs;
  double get monthlyEarnings => _monthlyEarnings;

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
          jobs.where((job) => job.status == Job.STATUS_COMPLETED).length;
      final cancelledJobs =
          jobs.where((job) => job.status == Job.STATUS_CANCELLED).length;

      // Calculate jobs by status
      final jobsByStatus = <String, int>{};
      for (final job in jobs) {
        jobsByStatus[job.status] = (jobsByStatus[job.status] ?? 0) + 1;
      }

      // Calculate earnings by month
      final earningsByMonth = <String, double>{};
      for (final job in jobs) {
        if (job.status == Job.STATUS_COMPLETED) {
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
          .where((job) => job.status == Job.STATUS_COMPLETED)
          .fold<double>(0, (sum, job) => sum + job.price);

      // Calculate weekly earnings
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final weeklyEarnings = jobs
          .where((job) =>
              job.status == Job.STATUS_COMPLETED &&
              job.date.isAfter(weekStart) &&
              job.date.isBefore(weekEnd))
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
        if (job.status == Job.STATUS_COMPLETED &&
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

  void _calculateStats(List<Job> jobs) {
    _totalJobs = jobs.length;
    _completedJobs =
        jobs.where((job) => job?.status == Job.STATUS_COMPLETED).length;
    _cancelledJobs =
        jobs.where((job) => job?.status == Job.STATUS_CANCELLED).length;
    _totalEarnings = 0;

    for (final job in jobs) {
      if (job?.status == Job.STATUS_COMPLETED && job?.price != null) {
        _totalEarnings += job!.price!;
      }
    }

    notifyListeners();
  }

  void _calculateWeeklyStats(List<Job> jobs) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    _weeklyCompletedJobs = jobs
        .where((job) =>
            job?.status == Job.STATUS_COMPLETED &&
            job?.date != null &&
            job!.date!.isAfter(weekStart) &&
            job.date!.isBefore(weekEnd))
        .length;

    _weeklyEarnings = jobs
        .where((job) =>
            job?.status == Job.STATUS_COMPLETED &&
            job?.date != null &&
            job!.date!.isAfter(weekStart) &&
            job.date!.isBefore(weekEnd) &&
            job.price != null)
        .fold(0, (sum, job) => sum + job.price!);

    notifyListeners();
  }

  void _calculateMonthlyStats(List<Job> jobs) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    _monthlyCompletedJobs = jobs
        .where((job) =>
            job?.status == Job.STATUS_COMPLETED &&
            job?.date != null &&
            job!.date!.isAfter(monthStart) &&
            job.date!.isBefore(monthEnd))
        .length;

    _monthlyEarnings = jobs
        .where((job) =>
            job?.status == Job.STATUS_COMPLETED &&
            job?.date != null &&
            job!.date!.isAfter(monthStart) &&
            job.date!.isBefore(monthEnd) &&
            job.price != null)
        .fold(0, (sum, job) => sum + job.price!);

    notifyListeners();
  }
}
