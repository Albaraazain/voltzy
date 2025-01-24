import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatelessWidget {
  final Set<Marker> markers;
  final LatLng initialPosition;
  final double initialZoom;
  final void Function(GoogleMapController)? onMapCreated;
  final void Function(LatLng)? onTap;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;

  const MapView({
    super.key,
    required this.markers,
    required this.initialPosition,
    this.initialZoom = 15.0,
    this.onMapCreated,
    this.onTap,
    this.myLocationEnabled = true,
    this.myLocationButtonEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: initialZoom,
      ),
      markers: markers,
      onMapCreated: onMapCreated,
      onTap: onTap,
      myLocationEnabled: myLocationEnabled,
      myLocationButtonEnabled: myLocationButtonEnabled,
      mapType: MapType.normal,
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
      compassEnabled: true,
    );
  }
}
