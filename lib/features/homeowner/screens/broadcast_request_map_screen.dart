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
  final double _searchRadius = 25.0; // Fixed 25km radius
  int _nearbyProfessionalsCount = 0;
  bool _isLoading = false;
  bool _isRequestingJob = false;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(widget.initialLat, widget.initialLng);
    LoggerService.debug('Initial location: $_selectedLocation');
    _updateNearbyProfessionalsCount();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _updateNearbyProfessionalsCount() async {
    setState(() => _isLoading = true);
    try {
      LoggerService.debug(
          'Counting professionals at: $_selectedLocation with radius: $_searchRadius km');
      final count = await Provider.of<DatabaseProvider>(context, listen: false)
          .countNearbyProfessionals(
        serviceId: widget.service.id,
        lat: _selectedLocation.latitude,
        lng: _selectedLocation.longitude,
        radiusKm: _searchRadius,
      );
      LoggerService.debug('Found $count professionals');
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
      LoggerService.debug('Creating broadcast job:');
      LoggerService.debug('- Service: ${widget.service.name}');
      LoggerService.debug('- Location: $_selectedLocation');
      LoggerService.debug('- Hours: ${widget.hours}');
      LoggerService.debug('- Budget: ${widget.budget}');
      LoggerService.debug('- Radius: $_searchRadius km');

      await Provider.of<DatabaseProvider>(context, listen: false)
          .createBroadcastJob(
        title: 'Service Request: ${widget.service.name}',
        description: widget.description,
        serviceId: widget.service.id,
        hours: widget.hours.toDouble(),
        pricePerHour: widget.budget / widget.hours,
        lat: _selectedLocation.latitude,
        lng: _selectedLocation.longitude,
        radiusKm: _searchRadius,
      );

      LoggerService.debug('Broadcast job created successfully');

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
          title: const Text('Service Area'),
          elevation: 0,
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: 14,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                LoggerService.debug('Map created');
              },
              circles: {
                Circle(
                  circleId: const CircleId('searchArea'),
                  center: _selectedLocation,
                  radius: _searchRadius * 1000, // Convert km to meters
                  fillColor: Colors.blue.withOpacity(0.2),
                  strokeColor: Colors.blue,
                  strokeWidth: 1,
                ),
              },
              markers: {
                Marker(
                  markerId: const MarkerId('homeLocation'),
                  position: _selectedLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure),
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
                            _isLoading
                                ? 'Searching for professionals...'
                                : '$_nearbyProfessionalsCount professionals found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your service request will be visible to professionals within ${_searchRadius.toStringAsFixed(1)} km',
                            style: Theme.of(context).textTheme.bodyMedium,
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
