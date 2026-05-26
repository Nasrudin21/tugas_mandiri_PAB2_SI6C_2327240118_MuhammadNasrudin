import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../models/traffic.dart';
import '../services/traffic_services.dart';

class AddTrafficScreen
    extends StatefulWidget {
  const AddTrafficScreen({super.key});

  @override
  State<AddTrafficScreen> createState() =>
      _AddTrafficScreenState();
}

class _AddTrafficScreenState
    extends State<AddTrafficScreen> {
  final TextEditingController
      _descriptionController =
      TextEditingController();

  String? _base64Image;

  String? _latitude;

  String? _longitude;

  String? _category;

  bool _isSubmitting = false;

  bool _isGettingLocation = false;

  List<String> get categories {
    return [
      'Macet Parah',
      'Padat Merayap',
      'Kecelakaan',
      'Perbaikan Jalan',
      'Lampu Merah Rusak',
    ];
  }

  Future<void>
      pickImageAndConvert() async {
    final ImagePicker picker =
        ImagePicker();

    final XFile? image =
        await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      final bytes =
          await image.readAsBytes();

      setState(() {
        _base64Image =
            base64Encode(bytes);
      });
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      bool serviceEnabled =
          await Geolocator
              .isLocationServiceEnabled();

      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission =
          await Geolocator
              .checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator
                .requestPermission();
      }

      Position position =
          await Geolocator
              .getCurrentPosition();

      setState(() {
        _latitude =
            position.latitude.toString();

        _longitude =
            position.longitude.toString();
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      _isGettingLocation = false;
    });
  }

  void _showCategorySelect() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: categories
              .map(
                (cat) => ListTile(
                  title: Text(cat),
                  onTap: () {
                    setState(() {
                      _category = cat;
                    });

                    Navigator.pop(
                      context,
                    );
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildImagePreview() {
    if (_base64Image == null) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius:
              BorderRadius.circular(12),
        ),
        child: const Text(
          'Belum ada gambar',
        ),
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(12),
      child: Image.memory(
        base64Decode(_base64Image!),
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Future<void> _submitTraffic() async {
    if (_base64Image == null) return;

    if (_category == null) return;

    if (_descriptionController.text
        .trim()
        .isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final userId =
        FirebaseAuth.instance.currentUser?.uid;

    final fullName =
        FirebaseAuth.instance.currentUser
            ?.displayName;

    await TrafficService.addTraffic(
      Traffic(
        image: _base64Image,
        description:
            _descriptionController.text,
        category: _category,
        latitude: _latitude,
        longitude: _longitude,
        userId: userId,
        userFullName: fullName,
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content:
            Text("Laporan berhasil"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Tambah Laporan"),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [
            _buildImagePreview(),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed:
                  pickImageAndConvert,
              child: const Text(
                'Pick Image',
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed:
                  _showCategorySelect,
              child: const Text(
                'Select Category',
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _category ??
                  'Belum memilih kategori',
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  _descriptionController,
              maxLines: 4,
              decoration:
                  const InputDecoration(
                labelText: 'Deskripsi',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed:
                  _isGettingLocation
                      ? null
                      : _getLocation,
              child: Text(
                _isGettingLocation
                    ? 'Mengambil Lokasi...'
                    : 'Get Location',
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _latitude == null
                  ? 'Lokasi belum diambil'
                  : 'Lat: $_latitude\nLng: $_longitude',
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed:
                  _isSubmitting
                      ? null
                      : _submitTraffic,

              child: Text(
                _isSubmitting
                    ? 'Submitting...'
                    : 'Submit',
              ),
            ),
          ],
        ),
      ),
    );
  }
}