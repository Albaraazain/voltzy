import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_service.dart';
import '../../../providers/database_provider.dart';
import '../../../models/professional_model.dart';

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
  late GoogleMapController _mapController;
  late Position _currentPosition;
  late List<Professional> _professionals;
  late LatLng _selectedLocation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      // Get current location
      _currentPosition = await LocationService.getCurrentLocation();

      // Load professionals
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
      await dbProvider.loadProfessionals();
      _professionals = dbProvider.professionals;

      // Set initial map position
      _selectedLocation = LatLng(
        _currentPosition.latitude,
        _currentPosition.longitude,
      );

      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onLocationSelected(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: 14.0,
              ),
              onTap: _onLocationSelected,
              markers: {
                Marker(
                  markerId: const MarkerId('selected_location'),
                  position: _selectedLocation,
                ),
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context, _selectedLocation),
        child: const Icon(Icons.check),
      ),
    );
  }
}
