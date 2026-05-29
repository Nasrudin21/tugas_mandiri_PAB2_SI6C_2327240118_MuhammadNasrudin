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

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
  }

  String generateAvatarUrl(String? fullName) {
    final name = (fullName == null || fullName.trim().isEmpty)
        ? 'Pengguna'
        : fullName.trim();
    final formattedName = Uri.encodeComponent(name);

    return 'https://ui-avatars.com/api/?name=$formattedName&background=1E3A8A&color=fff&bold=true';
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
    final result = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pilih Kategori',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tampilkan laporan sesuai kondisi jalan.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
                const SizedBox(height: 18),
                _FilterTile(
                  icon: Icons.apps_rounded,
                  label: 'Semua Kategori',
                  isSelected: selectedCategory == null,
                  onTap: () => Navigator.pop(context, null),
                ),
                const SizedBox(height: 8),
                ...categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _FilterTile(
                      icon: _iconForCategory(category),
                      label: category,
                      isSelected: selectedCategory == category,
                      onTap: () => Navigator.pop(context, category),
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currentUserId = user?.uid;
    final displayName =
        (user?.displayName == null || user!.displayName!.trim().isEmpty)
        ? 'Pengguna Jalan'
        : user.displayName!.trim();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Monitoring Kemacetan',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Filter kategori',
            onPressed: _showCategoryFilter,
            icon: const Icon(Icons.tune_rounded),
          ),
          IconButton(
            tooltip: 'Keluar',
            onPressed: signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFFF8FAFC)],
            stops: [0, 0.42, 0.42],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                child: _HeroProfileCard(
                  displayName: displayName,
                  avatarUrl: generateAvatarUrl(displayName),
                  selectedCategory: selectedCategory,
                  onFilterTap: _showCategoryFilter,
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: StreamBuilder(
                    stream: TrafficService.getTrafficListByCategory(
                      selectedCategory,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _LoadingState();
                      }

                      final traffics = snapshot.data ?? [];

                      if (traffics.isEmpty) {
                        return _EmptyState(
                          selectedCategory: selectedCategory,
                          onResetFilter: selectedCategory == null
                              ? null
                              : () {
                                  setState(() {
                                    selectedCategory = null;
                                  });
                                },
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 18, 14, 110),
                        itemCount: traffics.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Laporan Terkini',
                                          style: TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          selectedCategory ?? 'Semua kategori',
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _CountBadge(count: traffics.length),
                                ],
                              ),
                            );
                          }

                          final traffic = traffics[index - 1];
                          final isOwner =
                              currentUserId != null &&
                              traffic.userId == currentUserId;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TrafficListItem(
                              traffic: traffic,
                              isOwner: isOwner,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFEA580C),
        foregroundColor: Colors.white,
        elevation: 8,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTrafficScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Laporan',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _HeroProfileCard extends StatelessWidget {
  final String displayName;
  final String avatarUrl;
  final String? selectedCategory;
  final VoidCallback onFilterTap;

  const _HeroProfileCard({
    required this.displayName,
    required this.avatarUrl,
    required this.selectedCategory,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(avatarUrl),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Datang',
                  style: TextStyle(
                    color: Color(0xFFBFDBFE),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onFilterTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.filter_alt_rounded,
                          color: Color(0xFF1E3A8A),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            selectedCategory ?? 'Semua kategori',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1E3A8A),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(18),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: CircleAvatar(
          backgroundColor: isSelected
              ? const Color(0xFF1E3A8A)
              : const Color(0xFFE2E8F0),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A))
            : const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDD5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count laporan',
        style: const TextStyle(
          color: Color(0xFFC2410C),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String? selectedCategory;
  final VoidCallback? onResetFilter;

  const _EmptyState({
    required this.selectedCategory,
    required this.onResetFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.route_rounded,
                color: Color(0xFF1E3A8A),
                size: 46,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              selectedCategory == null
                  ? 'Belum ada laporan'
                  : 'Belum ada laporan $selectedCategory',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Laporkan kondisi jalan terbaru agar pengguna lain bisa memilih rute dengan lebih nyaman.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            if (onResetFilter != null) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: onResetFilter,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tampilkan semua'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
