import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../providers/database_provider.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../models/service_model.dart';

class BroadcastRequestMapScreen extends StatefulWidget {
  final Service service;
  final double initialLat;
  final double initialLng;

  const BroadcastRequestMapScreen({
    super.key,
    required this.service,
    required this.initialLat,
    required this.initialLng,
  });

  @override
  State<BroadcastRequestMapScreen> createState() =>
      _BroadcastRequestMapScreenState();
}

class _BroadcastRequestMapScreenState extends State<BroadcastRequestMapScreen> {
  GoogleMapController? _mapController;
  bool _isLoading = true;
  int _nearbyProfessionalsCount = 0;
  double _selectedRadius = 5.0; // Default 5km radius
  late LatLng _selectedLocation;
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
        description: 'Broadcast request for ${widget.service.name}',
        serviceId: widget.service.id,
        hours: 2.0, // Default hours, could be made configurable
        pricePerHour: widget.service.basePrice,
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Request ${widget.service.name}'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              setState(() => _isLoading = false);
            },
            circles: {
              Circle(
                circleId: const CircleId('searchRadius'),
                center: _selectedLocation,
                radius: _selectedRadius * 1000, // Convert km to meters
                fillColor: Colors.blue.withOpacity(0.2),
                strokeColor: Colors.blue,
                strokeWidth: 1,
              ),
            },
            onTap: (location) {
              setState(() => _selectedLocation = location);
              _updateNearbyProfessionalsCount();
            },
          ),
          // Bottom Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoading)
                      const LoadingIndicator()
                    else ...[
                      Text(
                        'Found $_nearbyProfessionalsCount professionals nearby',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Within ${_selectedRadius.toStringAsFixed(1)} km radius',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Slider(
                        value: _selectedRadius,
                        min: 1.0,
                        max: 20.0,
                        divisions: 19,
                        label: '${_selectedRadius.toStringAsFixed(1)} km',
                        onChanged: (value) {
                          setState(() => _selectedRadius = value);
                          _updateNearbyProfessionalsCount();
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _nearbyProfessionalsCount > 0 && !_isRequestingJob
                                  ? _requestBroadcastJob
                                  : null,
                          child: Text(_isRequestingJob
                              ? 'Sending Request...'
                              : 'Request Service'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
