import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/professional_model.dart';
import '../../../providers/database_provider.dart';
import '../../../core/services/location_service.dart';
import 'package:provider/provider.dart';

class DirectRequestMapScreen extends StatefulWidget {
  final String service;
  final DateTime scheduledDate;
  final double hours;
  final double radiusKm;
  final double? locationLat;
  final double? locationLng;
  final double? maxBudgetPerHour;

  const DirectRequestMapScreen({
    super.key,
    required this.service,
    required this.scheduledDate,
    required this.hours,
    required this.radiusKm,
    this.locationLat,
    this.locationLng,
    this.maxBudgetPerHour,
  });

  @override
  State<DirectRequestMapScreen> createState() => _DirectRequestMapScreenState();
}

class _DirectRequestMapScreenState extends State<DirectRequestMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Professional> _professionals = [];
  bool _isLoading = false;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _loadProfessionals();
  }

  Future<void> _loadProfessionals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<DatabaseProvider>().loadProfessionals();
      final professionals = context.read<DatabaseProvider>().professionals;

      setState(() {
        _professionals = professionals;
        _markers = professionals.map((professional) {
          final lat = professional.locationLat ?? 0.0;
          final lng = professional.locationLng ?? 0.0;
          final position = LatLng(lat, lng);

          return Marker(
            markerId: MarkerId(professional.id),
            position: position,
            infoWindow: InfoWindow(
              title: professional.profile?.name ?? 'Unknown Professional',
              snippet: 'Tap to view profile',
            ),
            onTap: () => _onMarkerTapped(professional),
          );
        }).toSet();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading professionals: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMarkerTapped(Professional professional) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              professional.profile?.name ?? 'Unknown Professional',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Hourly Rate: \$${professional.hourlyRate}/hr',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _selectProfessional(professional);
                  },
                  child: const Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectProfessional(Professional professional) {
    Navigator.pushNamed(
      context,
      '/homeowner/direct-request-job',
      arguments: {
        'professional': professional,
        'service': widget.service,
        'maxBudgetPerHour': widget.maxBudgetPerHour,
        'hours': widget.hours,
        'scheduledDate': widget.scheduledDate,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Professional'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 12,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              LocationService.getCurrentLocation().then((position) {
                if (mounted) {
                  controller.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(position.latitude, position.longitude),
                    ),
                  );
                }
              });
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
