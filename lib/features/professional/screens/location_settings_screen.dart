import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/services/location_service.dart';
import '../../../providers/database_provider.dart';
import '../../../services/logger_service.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isLoading = false;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final location = await LocationService.getCurrentLocation();
      final latLng = LatLng(location.latitude, location.longitude);
      _updateMarker(latLng);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
        } catch (e) {
      LoggerService.error('Error getting current location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get current location')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          draggable: true,
          onDragEnd: _updateMarker,
        ),
      };
    });
  }

  Future<void> _saveLocation() async {
    if (_selectedLocation == null) return;

    setState(() => _isLoading = true);
    try {
      final dbProvider = context.read<DatabaseProvider>();
      await dbProvider.updateProfessionalLocation(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
        5.0, // Default radius of 5km
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      LoggerService.error('Error saving location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update location')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Settings'),
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: _isLoading ? null : _saveLocation,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Drag the marker to set your location or tap anywhere on the map',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(0, 0),
                    zoom: 2,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onTap: _updateMarker,
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
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
