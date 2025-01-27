import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/widgets/map_view.dart';
import '../../../models/location_model.dart';
import '../../../models/base_service_model.dart';
import '../../../providers/database_provider.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../models/job_model.dart';
import 'package:geolocator/geolocator.dart';

enum SearchState {
  searching,
  requesting,
  success,
  failed,
}

class FindProfessionalMapScreen extends StatefulWidget {
  final BaseService service;
  final int? hours;
  final String? additionalNotes;
  final double? maxBudgetPerHour;
  final DateTime? scheduledDate;
  final TimeOfDay? scheduledTime;

  const FindProfessionalMapScreen({
    super.key,
    required this.service,
    this.hours,
    this.maxBudgetPerHour,
    this.scheduledDate,
    this.scheduledTime,
    this.additionalNotes,
  });

  @override
  State<FindProfessionalMapScreen> createState() =>
      _FindProfessionalMapScreenState();
}

class _FindProfessionalMapScreenState extends State<FindProfessionalMapScreen>
    with SingleTickerProviderStateMixin {
  Set<Marker> _markers = {};
  LocationModel? _currentLocation;
  bool _isLoading = true;
  SearchState _searchState = SearchState.searching;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  String? _jobId;

  final _defaultLocation = const LocationModel(
    latitude: 41.0082, // Istanbul's coordinates
    longitude: 28.9784,
  );

  @override
  void initState() {
    super.initState();
    LoggerService.debug('Initializing FindProfessionalMapScreen');
    _initializeMap();
    _setupAnimations();
    _startSearching();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _slideController.forward();
  }

  Future<void> _initializeMap() async {
    try {
      LoggerService.debug('Starting map initialization');
      setState(() => _isLoading = true);

      final dbProvider = context.read<DatabaseProvider>();
      LoggerService.debug('DatabaseProvider state: ${dbProvider.toString()}');

      // Force reload professionals
      await dbProvider.loadProfessionals();
      LoggerService.debug('Reloaded professionals from database');

      final position = await LocationService.getCurrentLocation();
      _currentLocation = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      LoggerService.debug(
          'Current location: ${position.latitude}, ${position.longitude}');

      await _loadProfessionals();
    } catch (e) {
      LoggerService.error('Failed to initialize map: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load map data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadProfessionals() async {
    try {
      LoggerService.debug('Starting professional search');
      setState(() {
        _isLoading = true;
      });

      final currentLocation = await LocationService.getCurrentLocation();
      LoggerService.debug(
          'Current location: ${currentLocation.latitude ?? 0}, ${currentLocation.longitude ?? 0}');

      final dbProvider = context.read<DatabaseProvider>();
      final professionals = dbProvider.professionals;
      LoggerService.debug(
          'Total professionals in database: ${professionals.length}');

      // Filter professionals: must be available and verified
      final availableprofessionals = professionals.where((e) {
        final hasLocation = e.locationLat != null && e.locationLng != null;
        final maxBudget = widget.maxBudgetPerHour ?? double.infinity;
        final withinBudget = e.hourlyRate == null || e.hourlyRate! <= maxBudget;

        double lat = e.locationLat ?? 0.0;
        double lng = e.locationLng ?? 0.0;
        double distance = Geolocator.distanceBetween(
              currentLocation.latitude,
              currentLocation.longitude,
              lat,
              lng,
            ) /
            1000;
        LoggerService.debug('professional ${e.profile?.name ?? 'Unknown'}: '
            'available=${e.isAvailable}, '
            'verified=${e.isVerified}, '
            'rate=${e.hourlyRate}, '
            'hasLocation=$hasLocation, '
            'withinBudget=$withinBudget, '
            'distance=$distance');
        return e.isAvailable && e.isVerified && withinBudget && hasLocation;
      }).toList();

      LoggerService.debug(
          'Found ${availableprofessionals.length} available professionals');

      if (availableprofessionals.isEmpty) {
        LoggerService.debug(
            'No professionals available, setting state to failed');
        setState(() {
          _isLoading = false;
          _markers = {};
        });
        return;
      }

      final markers = availableprofessionals.map((professional) {
        final position = LatLng(
          professional.locationLat ?? 0.0,
          professional.locationLng ?? 0.0,
        );
        LoggerService.debug(
            'Creating marker for ${professional.profile?.name ?? 'Unknown'} at location: ${position.latitude}, ${position.longitude}');

        return Marker(
          markerId: MarkerId('professional_${professional.id}'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: professional.profile?.name ?? 'Unknown',
            snippet:
                '${professional.rating} ★ - ${professional.hourlyRate}₺/hr',
          ),
        );
      }).toSet();

      LoggerService.debug('Created ${markers.length} markers');

      setState(() {
        _isLoading = false;
        _markers = markers;
      });
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load professionals', e, stackTrace);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startSearching() async {
    LoggerService.debug('Starting professional search');
    setState(() => _searchState = SearchState.searching);

    try {
      final currentLocation = await LocationService.getCurrentLocation();
      LoggerService.debug(
          'Current location: ${currentLocation.latitude ?? 0}, ${currentLocation.longitude ?? 0}');

      final dbProvider = context.read<DatabaseProvider>();
      final professionals = dbProvider.professionals;
      LoggerService.debug(
          'Total professionals in database: ${professionals.length}');

      // Use same filtering as _loadProfessionals
      final availableprofessionals = professionals
          .where((e) =>
              e.isAvailable &&
              e.isVerified &&
              (e.hourlyRate ?? 0) <= (widget.maxBudgetPerHour ?? 0))
          .toList();

      LoggerService.debug(
          'Found ${availableprofessionals.length} available professionals');

      if (availableprofessionals.isEmpty) {
        LoggerService.debug(
            'No professionals available, setting state to failed');
        setState(() => _searchState = SearchState.failed);
        return;
      }

      // Set success state after finding professionals
      setState(() => _searchState = SearchState.success);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to search for professionals', e, stackTrace);
      setState(() => _searchState = SearchState.failed);
    }
  }

  Future<void> _createJobRequest() async {
    if (mounted) {
      setState(() => _searchState = SearchState.requesting);
    }

    try {
      final dbProvider = context.read<DatabaseProvider>();
      final currentLocation = _currentLocation;

      // Create job request without specifying an professional_id
      final job = await dbProvider.createJobRequest(
        title: widget.service.name,
        description: widget.additionalNotes ?? '',
        scheduledDate: widget.scheduledDate ?? DateTime.now(),
        price: widget.maxBudgetPerHour! * widget.hours!,
        locationLat: currentLocation?.latitude ?? 0,
        locationLng: currentLocation?.longitude ?? 0,
        radiusKm: 10, // Default 10km radius
      );

      if (mounted) {
        setState(() {
          _searchState = SearchState.requesting;
          _jobId = job.id;
        });
      }

      // Start listening for job status updates
      _listenForJobUpdates(job.id);
    } catch (e) {
      if (mounted) {
        setState(() => _searchState = SearchState.failed);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create job request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map View
          MapView(
            initialPosition: LatLng(
              _currentLocation?.latitude ?? _defaultLocation.latitude,
              _currentLocation?.longitude ?? _defaultLocation.longitude,
            ),
            markers: _markers,
            initialZoom: 12,
            onMapCreated: (controller) {
              // Map initialization logic
            },
          ),

          // Back Button with Gradient
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Card with Status
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildBottomCardContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCardContent() {
    switch (_searchState) {
      case SearchState.searching:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Finding professionals...',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Searching for available professionals in your area',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case SearchState.requesting:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Requesting service...',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Waiting for a professional to accept your request',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Cancel Request'),
              ),
            ),
          ],
        );

      case SearchState.success:
        if (_jobId == null) {
          // Show the "Request Job" button when professionals are found
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Professionals Found!',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${_markers.length} professionals available nearby',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _createJobRequest(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Request Job',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        // Show confirmation when a professional accepts
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Professional Assigned!',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'A professional has accepted your request',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to job details or chat
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'View Details',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );

      case SearchState.failed:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'No professionals available',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your budget or schedule',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ),
          ],
        );
    }
  }

  void _listenForJobUpdates(String jobId) {
    final dbProvider = context.read<DatabaseProvider>();

    dbProvider.streamJobUpdates(jobId).listen(
      (job) {
        if (!mounted) return;

        if (job == null) {
          setState(() => _searchState = SearchState.failed);
          return;
        }

        switch (job.status) {
          case Job.STATUS_SCHEDULED:
            setState(() => _searchState = SearchState.success);
            break;
          case 'expired':
          case 'cancelled':
            setState(() => _searchState = SearchState.failed);
            break;
          default:
            // Keep showing requesting state
            break;
        }
      },
      onError: (error) {
        LoggerService.error('Error listening to job updates', error);
        if (mounted) {
          setState(() => _searchState = SearchState.failed);
        }
      },
    );
  }

  void _updateMarkers() {
    final markers = <Marker>{};
    for (final professional in _markers) {
      final maxPrice = widget.maxBudgetPerHour ?? double.infinity;
      final priceStr =
          professional.infoWindow.snippet?.split('₺/hr')[0].trim() ?? '0';
      final price = double.tryParse(priceStr) ?? 0.0;
      if (price <= maxPrice) {
        final position = professional.position;
        final marker = Marker(
          markerId: professional.markerId,
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: professional.infoWindow,
        );
        markers.add(marker);
      }
    }
    setState(() {
      _markers = markers;
    });
  }
}
