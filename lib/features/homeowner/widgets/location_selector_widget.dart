import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/database_provider.dart';
import '../../../core/services/logger_service.dart';

class LocationSelectorWidget extends StatelessWidget {
  const LocationSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseProvider = context.watch<DatabaseProvider>();
    final homeowner = databaseProvider.currentHomeowner;
    final hasLocation =
        homeowner?.locationLat != null && homeowner?.locationLng != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade400,
            Colors.orange.shade400,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade200.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            try {
              final result = await Navigator.pushNamed(
                context,
                '/set-location',
                arguments: {
                  'initialLat': homeowner?.locationLat ?? 41.0082,
                  'initialLng': homeowner?.locationLng ?? 28.9784,
                },
              );

              if (result != null && context.mounted) {
                final Map<String, double> location =
                    result as Map<String, double>;
                await databaseProvider.updateHomeownerLocation(
                  location['lat']!,
                  location['lng']!,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Location updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            } catch (e) {
              LoggerService.error('Error updating location: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update location'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    hasLocation ? Icons.location_on : Icons.location_searching,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasLocation
                            ? 'Service Location Set'
                            : 'Set Service Location',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasLocation
                            ? 'Your service area is ready'
                            : 'Tap to set your service location',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.8),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
