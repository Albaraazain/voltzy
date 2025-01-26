import 'package:flutter/material.dart';
import '../../../models/job_model.dart';
import '../../../core/theme/colors.dart';
import 'package:lottie/lottie.dart';

class JobSearchScreen extends StatefulWidget {
  final Job job;

  const JobSearchScreen({
    super.key,
    required this.job,
  });

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  bool _isSearching = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startSearching();
  }

  Future<void> _startSearching() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulated delay
    if (mounted) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSearching) ...[
                Lottie.asset(
                  'assets/animations/searching.json',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 24),
                Text(
                  'Finding Professionals',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'We\'re searching for professionals who match your requirements...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ] else if (_error != null) ...[
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Search Failed',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isSearching = true;
                    });
                    _startSearching();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Try Again'),
                ),
              ] else ...[
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: AppColors.success,
                ),
                const SizedBox(height: 24),
                Text(
                  'Professionals Found!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your request has been sent to nearby professionals.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('View Job Details'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
