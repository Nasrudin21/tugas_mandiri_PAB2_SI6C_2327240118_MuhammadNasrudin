import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:monitoring_kemacetan/models/traffic.dart';
import 'package:monitoring_kemacetan/services/traffic_services.dart';
import 'package:monitoring_kemacetan/screens/detail_screen.dart';

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

      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => DetailScreen(
                    traffic: traffic,
                  ),
            ),
          );
        },

        leading:
            traffic.image != null
                ? ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                        8,
                      ),

                  child: Image.memory(
                    base64Decode(
                      traffic.image!,
                    ),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
                : const Icon(
                  Icons.image,
                  size: 50,
                ),

        title: Text(
          traffic.category ??
              'No Category',
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              traffic.description ??
                  '',
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            Text(
              traffic.userFullName ??
                  '',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),

        isThreeLine: true,

        trailing:
            isOwner
                ? IconButton(
                  onPressed:
                      () =>
                          _deleteTraffic(
                            context,
                          ),

                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                )
                : null,
      ),
    );
  }
}