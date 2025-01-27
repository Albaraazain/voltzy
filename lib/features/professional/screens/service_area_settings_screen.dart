import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../../../providers/database_provider.dart';
import '../../../repositories/service_repository.dart';
import '../../../models/professional_service_model.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/config/api_keys.dart';

class ServiceAreaSettingsScreen extends StatefulWidget {
  final ProfessionalService service;

  const ServiceAreaSettingsScreen({
    super.key,
    required this.service,
  });

  @override
  State<ServiceAreaSettingsScreen> createState() =>
      _ServiceAreaSettingsScreenState();
}

class _ServiceAreaSettingsScreenState extends State<ServiceAreaSettingsScreen> {
  late TextEditingController _centerController;
  late TextEditingController _radiusController;
  late String _selectedUnit;
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  Position? _currentPosition;
  final _googleApiKey = ApiKeys.googlePlaces;

  @override
  void initState() {
    super.initState();
    _centerController =
        TextEditingController(text: widget.service.serviceAreaCenter);
    _radiusController = TextEditingController(
        text: widget.service.serviceAreaRadius.toString());
    _selectedUnit = widget.service.serviceAreaUnit;
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _centerController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address =
            '${place.street}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}';
        setState(() {
          _currentPosition = position;
          _centerController.text = address;
        });
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get current location', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get current location')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Widget _buildLocationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GooglePlaceAutoCompleteTextField(
          textEditingController: _centerController,
          googleAPIKey: _googleApiKey,
          inputDecoration: InputDecoration(
            hintText: 'Enter your service center location',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: _isLoadingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: _getCurrentLocation,
                  ),
          ),
          debounceTime: 800,
          countries: const ['us', 'ca'], // Add your supported countries
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (Prediction prediction) {
            // Handle the selected place if needed
          },
          itemClick: (Prediction prediction) {
            _centerController.text = prediction.description ?? '';
            _centerController.selection = TextSelection.fromPosition(
              TextPosition(offset: _centerController.text.length),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your address or use current location',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _saveChanges() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final serviceRepo =
          ServiceRepository(context.read<DatabaseProvider>().client);
      final professionalId =
          context.read<DatabaseProvider>().currentProfessional!.id;

      final serviceArea = {
        'center': _centerController.text,
        'radius': int.tryParse(_radiusController.text) ?? 25,
        'unit': _selectedUnit,
      };

      await serviceRepo.updateProfessionalService(
        professionalId,
        widget.service.id,
        serviceArea: serviceArea,
      );

      if (!mounted) return;

      await context.read<DatabaseProvider>().refreshProfessionalData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service area updated successfully')),
      );
      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update service area', e, stackTrace);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update service area')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildInfoCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.chevron_left, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 4,
                          width: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.settings_outlined,
                        size: 24, color: Colors.grey[600]),
                  ],
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Service Area',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set the area where you provide this service',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Service Center
                _buildInfoCard(
                  title: 'Service Center',
                  child: _buildLocationInput(),
                ),

                // Service Radius
                _buildInfoCard(
                  title: 'Service Radius',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _radiusController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                hintText: 'Enter radius',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedUnit,
                              items: ['miles', 'kilometers']
                                  .map((unit) => DropdownMenuItem(
                                        value: unit,
                                        child: Text(unit),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedUnit = value);
                                }
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You will receive service requests within this radius',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Coverage Map Preview
                _buildInfoCard(
                  title: 'Coverage Area Preview',
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Map Preview Coming Soon',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[500],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
