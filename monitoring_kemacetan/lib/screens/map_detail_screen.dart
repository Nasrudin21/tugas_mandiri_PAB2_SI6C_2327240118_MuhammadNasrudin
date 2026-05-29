import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:monitoring_kemacetan/models/traffic.dart';

class MapDetailScreen extends StatelessWidget {
  final Traffic traffic;

  const MapDetailScreen({super.key, required this.traffic});

  @override
  Widget build(BuildContext context) {
    final lat = double.tryParse(traffic.latitude ?? '');

    final lng = double.tryParse(traffic.longitude ?? '');

    final hasLocation = lat != null && lng != null;

    final point = hasLocation ? LatLng(lat, lng) : const LatLng(0, 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Map Detail')),

      body: hasLocation
          ? FlutterMap(
              options: MapOptions(initialCenter: point, initialZoom: 15),

              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 80,
                      height: 80,

                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : const Center(child: Text('Lokasi tidak tersedia')),
    );
  }
}
