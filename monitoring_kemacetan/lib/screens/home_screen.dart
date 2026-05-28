import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:monitoring_kemacetan/services/traffic_services.dart';
import 'package:monitoring_kemacetan/widgets/traffic_list_item.dart';
import 'package:monitoring_kemacetan/screens/add_traffic_screen.dart';
import 'package:monitoring_kemacetan/screens/sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
String? selectedCategory;

List<String> get categories {
return [
'Macet Parah',
'Padat Merayap',
'Kecelakaan',
'Perbaikan Jalan',
'Lampu Merah Rusak',
];
}

IconData _iconForCategory(String? category) {
switch (category) {
case 'Macet Parah':
return Icons.traffic;
case 'Padat Merayap':
  return Icons.directions_car_filled;

case 'Kecelakaan':
  return Icons.warning_amber_rounded;

case 'Perbaikan Jalan':
  return Icons.construction_rounded;

case 'Lampu Merah Rusak':
  return Icons.traffic_outlined;

default:
  return Icons.dashboard_rounded;

}
}

void _showCategoryFilter() async {

final result =
await showModalBottomSheet<String?>(
context: context,
backgroundColor: Colors.transparent,
isScrollControlled: true,

builder: (context) {

  return Container(
    padding: const EdgeInsets.fromLTRB(
      20,
      12,
      20,
      28,
    ),

    decoration: const BoxDecoration(
      color: Colors.white,

      borderRadius:
          BorderRadius.vertical(
        top: Radius.circular(28),
      ),
    ),

    child: SafeArea(
      top: false,

      child: Column(
        mainAxisSize:
            MainAxisSize.min,

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Center(
            child: Container(
              width: 44,
              height: 5,

              decoration: BoxDecoration(
                color: const Color(
                  0xFFE2E8F0,
                ),

                borderRadius:
                    BorderRadius.circular(
                  999,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Pilih Kategori',

            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 22,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Tampilkan laporan sesuai kondisi jalan.',

            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 18),

          _FilterTile(
            icon: Icons.apps_rounded,
            label: 'Semua Kategori',

            isSelected:
                selectedCategory == null,

            onTap: () =>
                Navigator.pop(
              context,
              null,
            ),
          ),

          const SizedBox(height: 8),

          ...categories.map(

            (category) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 8,
              ),

              child: _FilterTile(
                icon:
                    _iconForCategory(
                  category,
                ),

                label: category,

                isSelected:
                    selectedCategory ==
                        category,

                onTap: () =>
                    Navigator.pop(
                  context,
                  category,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
},

);

setState(() {
selectedCategory = result;
});
}
}