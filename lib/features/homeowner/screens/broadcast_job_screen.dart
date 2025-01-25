import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/database_provider.dart';
import '../../../models/service_model.dart';
import '../../../core/services/location_service.dart';
import 'broadcast_request_map_screen.dart';

class BroadcastJobScreen extends StatefulWidget {
  final Service service;

  const BroadcastJobScreen({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  State<BroadcastJobScreen> createState() => _BroadcastJobScreenState();
}

class _BroadcastJobScreenState extends State<BroadcastJobScreen> {
  bool _isLoading = false;

  Future<void> _navigateToMap() async {
    setState(() => _isLoading = true);
    try {
      final location = await LocationService.getCurrentLocation();
      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BroadcastRequestMapScreen(
            service: widget.service,
            initialLat: location.latitude,
            initialLng: location.longitude,
          ),
        ),
      );

      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get location')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _navigateToMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('Getting your location...'),
      ),
    );
  }
}
