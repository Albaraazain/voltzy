import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/services/logger_service.dart';

class SetLocationScreen extends StatefulWidget {
  final double initialLat;
  final double initialLng;

  const SetLocationScreen({
    super.key,
    required this.initialLat,
    required this.initialLng,
  });

  @override
  State<SetLocationScreen> createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends State<SetLocationScreen> {
  late LatLng _selectedLocation;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(widget.initialLat, widget.initialLng);
    LoggerService.debug('Initial location: $_selectedLocation');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Your Location'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    LoggerService.debug(
                        'Saving location: ${_selectedLocation.latitude}, ${_selectedLocation.longitude}');
                    Navigator.pop(context, {
                      'lat': _selectedLocation.latitude,
                      'lng': _selectedLocation.longitude,
                    });
                  },
            child: const Text('Save'),
          ),
        ],
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
              LoggerService.debug('Map moved to: $_selectedLocation');
            },
            markers: {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: _selectedLocation,
                draggable: true,
                onDragEnd: (newPosition) {
                  setState(() {
                    _selectedLocation = newPosition;
                  });
                  LoggerService.debug('Marker dragged to: $_selectedLocation');
                },
              ),
            },
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: const Text(
                  'Drag map or marker to set location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
