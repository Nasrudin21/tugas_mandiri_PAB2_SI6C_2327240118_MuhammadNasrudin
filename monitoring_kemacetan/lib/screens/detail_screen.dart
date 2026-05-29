import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:monitoring_kemacetan/models/traffic.dart';
import 'package:monitoring_kemacetan/services/traffic_services.dart';
import 'package:monitoring_kemacetan/screens/map_detail_screen.dart';

class DetailScreen extends StatelessWidget {
  final Traffic traffic;

  const DetailScreen({super.key, required this.traffic});

  Future<void> _deleteTraffic(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Yakin ingin menghapus laporan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),

          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await TrafficService.deleteTraffic(traffic);

      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    final isOwner = currentUserId != null && traffic.userId == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(traffic.category ?? 'Detail Laporan'),

        actions: [
          if (isOwner)
            IconButton(
              onPressed: () => _deleteTraffic(context),
              icon: const Icon(Icons.delete),
            ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            if (traffic.image != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),

                child: Image.memory(
                  base64Decode(traffic.image!),

                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(24),

                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Chip(label: Text(traffic.category ?? '')),

                    const SizedBox(height: 16),

                    Text(
                      traffic.description ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Icon(Icons.person),

                        const SizedBox(width: 8),

                        Text(traffic.userFullName ?? ''),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Icon(Icons.location_on),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            '${traffic.latitude}, ${traffic.longitude}',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MapDetailScreen(traffic: traffic),
                          ),
                        );
                      },

                      icon: const Icon(Icons.map),

                      label: const Text('View Map'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
