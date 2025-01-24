class ProfessionalStats {
  final int totalJobs;
  final int completedJobs;
  final int cancelledJobs;
  final double averageRating;
  final double totalEarnings;
  final double weeklyEarnings;
  final Map<String, int> jobsByStatus;
  final Map<String, double> earningsByMonth;

  const ProfessionalStats({
    required this.totalJobs,
    required this.completedJobs,
    required this.cancelledJobs,
    required this.averageRating,
    required this.totalEarnings,
    required this.weeklyEarnings,
    required this.jobsByStatus,
    required this.earningsByMonth,
  });

  factory ProfessionalStats.initial() {
    return const ProfessionalStats(
      totalJobs: 0,
      completedJobs: 0,
      cancelledJobs: 0,
      averageRating: 0.0,
      totalEarnings: 0.0,
      weeklyEarnings: 0.0,
      jobsByStatus: {},
      earningsByMonth: {},
    );
  }

  ProfessionalStats copyWith({
    int? totalJobs,
    int? completedJobs,
    int? cancelledJobs,
    double? averageRating,
    double? totalEarnings,
    double? weeklyEarnings,
    Map<String, int>? jobsByStatus,
    Map<String, double>? earningsByMonth,
  }) {
    return ProfessionalStats(
      totalJobs: totalJobs ?? this.totalJobs,
      completedJobs: completedJobs ?? this.completedJobs,
      cancelledJobs: cancelledJobs ?? this.cancelledJobs,
      averageRating: averageRating ?? this.averageRating,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      weeklyEarnings: weeklyEarnings ?? this.weeklyEarnings,
      jobsByStatus: jobsByStatus ?? this.jobsByStatus,
      earningsByMonth: earningsByMonth ?? this.earningsByMonth,
    );
  }
}
