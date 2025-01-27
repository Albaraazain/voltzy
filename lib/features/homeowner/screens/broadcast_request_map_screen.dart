import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../models/base_service_model.dart';
import '../../../models/professional_model.dart';
import '../../../providers/database_provider.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/broadcast_request_status_card.dart';

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
  String _requestStatus = 'searching_professionals';
  Professional? _acceptedProfessional;
  Timer? _acceptanceCheckTimer;
  String? _jobId;
  final Set<Circle> _circles = {};
  final Set<Marker> _markers = {};

  static final CameraPosition _defaultCameraPosition = CameraPosition(
    target: const LatLng(0, 0),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(widget.initialLat, widget.initialLng);
    LoggerService.debug('Initial location: $_selectedLocation');
    _updateMapElements();
    _updateNearbyProfessionalsCount();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _acceptanceCheckTimer?.cancel();
    super.dispose();
  }

  void _updateMapElements() {
    _circles.clear();
    _markers.clear();

    // Add search radius circle
    _circles.add(
      Circle(
        circleId: const CircleId('searchArea'),
        center: _selectedLocation,
        radius: _searchRadius * 1000, // Convert km to meters
        fillColor: AppColors.primary.withOpacity(0.1),
        strokeColor: AppColors.primary.withOpacity(0.3),
        strokeWidth: 2,
      ),
    );

    // Add location marker
    _markers.add(
      Marker(
        markerId: const MarkerId('homeLocation'),
        position: _selectedLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
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
      setState(() {
        _nearbyProfessionalsCount = count;
        _requestStatus = 'professionals_found';
      });
    } catch (e) {
      LoggerService.error('Error counting nearby professionals: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to find nearby professionals'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestBroadcastJob() async {
    if (_isRequestingJob) return;

    setState(() {
      _isRequestingJob = true;
      _requestStatus = 'awaiting_acceptance';
    });

    try {
      LoggerService.debug('Creating broadcast job:');
      LoggerService.debug('- Service: ${widget.service.name}');
      LoggerService.debug('- Location: $_selectedLocation');
      LoggerService.debug('- Hours: ${widget.hours}');
      LoggerService.debug('- Budget: ${widget.budget}');
      LoggerService.debug('- Radius: $_searchRadius km');

      final jobId = await Provider.of<DatabaseProvider>(context, listen: false)
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

      setState(() => _jobId = jobId);
      _startAcceptanceCheck();

      LoggerService.debug('Broadcast job created successfully');
    } catch (e) {
      LoggerService.error('Error creating broadcast job: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send request'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _requestStatus = 'professionals_found');
      }
    } finally {
      if (mounted) {
        setState(() => _isRequestingJob = false);
      }
    }
  }

  void _startAcceptanceCheck() {
    _acceptanceCheckTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_jobId == null) {
        timer.cancel();
        return;
      }

      try {
        final professional =
            await Provider.of<DatabaseProvider>(context, listen: false)
                .checkJobAcceptance(_jobId!);

        if (professional != null) {
          timer.cancel();
          if (mounted) {
            setState(() {
              _acceptedProfessional = professional;
              _requestStatus = 'professional_accepted';
            });
          }
        }
      } catch (e) {
        LoggerService.error('Error checking job acceptance: $e');
      }
    });
  }

  Future<void> _confirmJob() async {
    if (_jobId == null || _acceptedProfessional == null) return;

    setState(() => _isLoading = true);
    try {
      await Provider.of<DatabaseProvider>(context, listen: false)
          .confirmBroadcastJob(_jobId!, _acceptedProfessional!.id);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      LoggerService.error('Error confirming job: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to confirm job'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Service Area',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: AppColors.onSurface,
            onPressed: () => Navigator.pop(context),
          ),
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
              circles: _circles,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BroadcastRequestStatusCard(
                status: _requestStatus,
                professionalCount: _nearbyProfessionalsCount,
                acceptedProfessional: _acceptedProfessional,
                onRequestJob: _requestStatus == 'professionals_found'
                    ? _requestBroadcastJob
                    : null,
                onConfirmJob: _requestStatus == 'professional_accepted'
                    ? _confirmJob
                    : null,
                isLoading: _isRequestingJob || _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
