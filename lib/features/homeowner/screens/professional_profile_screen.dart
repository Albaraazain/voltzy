import 'package:flutter/material.dart';
import '../../../models/professional_model.dart';
import '../../../core/constants/colors.dart';

class ProfessionalProfileScreen extends StatelessWidget {
  final Professional professional;
  final bool showBookButton;

  const ProfessionalProfileScreen({
    super.key,
    required this.professional,
    this.showBookButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(professional.profile.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 24),
            _buildServicesSection(context),
            const SizedBox(height: 24),
            _buildAvailabilitySection(context),
            const SizedBox(height: 24),
            _buildReviewsSection(context),
          ],
        ),
      ),
      bottomNavigationBar: showBookButton ? _buildBookButton(context) : null,
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    professional.profile.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  ...[
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber[700], size: 20),
                        const SizedBox(width: 4),
                        Text(
                          professional.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '\$${professional.hourlyRate.toStringAsFixed(2)}/hr',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (professional.bio != null && professional.bio!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            professional.bio!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: professional.services.map((service) {
            return Chip(
              label: Text(service.name),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              labelStyle: TextStyle(color: AppColors.primary),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        // TODO: Add availability viewer widget
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        // TODO: Add reviews list widget
      ],
    );
  }

  Widget _buildBookButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            // TODO: Navigate to booking screen
          },
          child: const Text('Book Now'),
        ),
      ),
    );
  }
}
