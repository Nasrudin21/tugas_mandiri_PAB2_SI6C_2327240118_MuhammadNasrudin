import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:monitoring_kemacetan/models/traffic.dart';
import 'package:monitoring_kemacetan/services/traffic_services.dart';


class TrafficListItem
    extends StatelessWidget {
  final Traffic traffic;
  final bool isOwner;
  const TrafficListItem({
    super.key,
    required this.traffic,
    required this.isOwner,
  });

  Future<void> _deleteTraffic(
    BuildContext context,
  ) async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text(
              'Delete Report',
            ),
            content: const Text(
              'Yakin hapus laporan?',
            ),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.pop(
                      ctx,
                      false,
                    ),
                child: const Text(
                  'Cancel',
                ),
              ),

              TextButton(
                onPressed:
                    () => Navigator.pop(
                      ctx,
                      true,
                    ),
                child: const Text(
                  'Delete',
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await TrafficService.deleteTraffic(
        traffic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}