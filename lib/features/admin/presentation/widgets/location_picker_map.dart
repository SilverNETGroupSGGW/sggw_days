import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// An interactive map that lets the admin tap to select a location.
/// Returns the selected [LatLng] via [onLocationSelected].
class LocationPickerMap extends StatefulWidget {
  final LatLng? initialLocation;
  final ValueChanged<LatLng> onLocationSelected;

  const LocationPickerMap({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  static const LatLng _sggwCenter = LatLng(52.1598, 21.0463);

  late LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    final center = _selectedLocation ?? _sggwCenter;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 250,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 16.0,
            minZoom: 14.0,
            maxZoom: 19.0,
            onTap: (tapPosition, latLng) {
              setState(() => _selectedLocation = latLng);
              widget.onLocationSelected(latLng);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.sggw.days',
            ),
            if (_selectedLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation!,
                    width: 40,
                    height: 40,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
