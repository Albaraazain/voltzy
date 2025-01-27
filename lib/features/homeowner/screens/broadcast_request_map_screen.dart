import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../models/base_service_model.dart';
import '../../../providers/database_provider.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/widgets/loading_overlay.dart';

class BroadcastRequestMapScreen extends StatefulWidget {
  final BaseService service;
  final double initialLat;
  final double initialLng;
  final int hours;
  final double budget;
  final String description;

  const BroadcastRequestMapScreen({
    super.key,
    required this.service,
    required this.initialLat,
    required this.initialLng,
    required this.hours,
    required this.budget,
    required this.description,
  });

  @override
  State<BroadcastRequestMapScreen> createState() =>
      _BroadcastRequestMapScreenState();
}

class _BroadcastRequestMapScreenState extends State<BroadcastRequestMapScreen> {
  late LatLng _selectedLocation;
  double _selectedRadius = 5.0; // Default 5km radius
  int _nearbyProfessionalsCount = 0;
  bool _isLoading = false;
  bool _isRequestingJob = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(widget.initialLat, widget.initialLng);
    _updateNearbyProfessionalsCount();
  }

  Future<void> _updateNearbyProfessionalsCount() async {
    setState(() => _isLoading = true);
    try {
      final count = await Provider.of<DatabaseProvider>(context, listen: false)
          .countNearbyProfessionals(
        serviceId: widget.service.id,
        lat: _selectedLocation.latitude,
        lng: _selectedLocation.longitude,
        radiusKm: _selectedRadius,
      );
      setState(() => _nearbyProfessionalsCount = count);
    } catch (e) {
      LoggerService.error('Error counting nearby professionals: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to find nearby professionals')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestBroadcastJob() async {
    if (_isRequestingJob) return;

    setState(() => _isRequestingJob = true);
    try {
      await Provider.of<DatabaseProvider>(context, listen: false)
          .createBroadcastJob(
        title: 'Service Request: ${widget.service.name}',
        description: widget.description,
        serviceId: widget.service.id,
        hours: widget.hours.toDouble(),
        pricePerHour: widget.budget / widget.hours,
        lat: _selectedLocation.latitude,
        lng: _selectedLocation.longitude,
        radiusKm: _selectedRadius,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      LoggerService.error('Error creating broadcast job: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send request')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRequestingJob = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isRequestingJob,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Area'),
          elevation: 0,
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: 14,
              ),
              onCameraMove: (position) {
                setState(() {
                  _selectedLocation = position.target;
                });
              },
              onCameraIdle: _updateNearbyProfessionalsCount,
              circles: {
                Circle(
                  circleId: const CircleId('searchArea'),
                  center: _selectedLocation,
                  radius: _selectedRadius * 1000, // Convert km to meters
                  fillColor: Colors.blue.withOpacity(0.2),
                  strokeColor: Colors.blue,
                  strokeWidth: 1,
                ),
              },
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_nearbyProfessionalsCount professionals found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Search radius: ${_selectedRadius.toStringAsFixed(1)} km',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Slider(
                            value: _selectedRadius,
                            min: 1,
                            max: 50,
                            divisions: 49,
                            label: '${_selectedRadius.toStringAsFixed(1)} km',
                            onChanged: (value) {
                              setState(() {
                                _selectedRadius = value;
                              });
                              _updateNearbyProfessionalsCount();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _nearbyProfessionalsCount > 0
                        ? _requestBroadcastJob
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _nearbyProfessionalsCount > 0
                          ? 'Send Request to $_nearbyProfessionalsCount Professionals'
                          : 'No Professionals Found',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
