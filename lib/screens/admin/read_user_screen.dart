import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_services.dart';
import '../../widgets/admin_bottom_navbar.dart';
import 'create_user_screen.dart';
import 'update_user_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserService _service = UserService();

  List<AppUser> _allUsers = [];
  List<AppUser> _filteredUsers = [];

  String _search = '';
  String _category = 'Semua';

  final List<String> categories = ['Semua', 'admin', 'petugas', 'peminjam'];

  final Color primary = const Color(0xFF2F3A8F);

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    _allUsers = await _service.getAllUsers();
    _applyFilter();
  }

  void _applyFilter() {
    setState(() {
      _filteredUsers = _allUsers.where((u) {
        final matchSearch = u.nama.toLowerCase().contains(_search.toLowerCase()) ||
            u.email.toLowerCase().contains(_search.toLowerCase());

        final matchCategory = _category == 'Semua' || u.role == _category;

        return matchSearch && matchCategory;
      }).toList();
    });
  }

  // ================= ROLE STYLE =================

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color(0xFF2F3A8F);
      case 'petugas':
        return const Color(0xFF2E7D32);
      case 'peminjam':
        return const Color(0xFFF9A825);
      default:
        return Colors.grey;
    }
  }

  Widget _roleChip(String role) {
    final color = _roleColor(role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  // ================= DELETE =================

  void _confirmDelete(AppUser user) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 50),
            const SizedBox(height: 10),
            const Text('Hapus Pengguna',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Yakin ingin menghapus ${user.nama}?'),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      try {
                        await _service.deleteUser(user.id);

                        if (!mounted) return;

                        await _fetchUsers();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Penggunaberhasil dihapus'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal menghapus pengguna: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Hapus'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}


  // ================= ACTION ICON =================

  Widget _iconAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.8),
        color: Colors.white,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 18,
        icon: Icon(icon, color: color),
        onPressed: onTap,
      ),
    );
  }

  // ================= USER CARD =================

  Widget _userCard(AppUser u) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary, width: 2),
        color: Colors.white,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE3E6F3),
            child: Text(
              u.nama.isNotEmpty ? u.nama[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Color(0xFF2F345D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  u.nama,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(u.email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),

                // ROLE CHIP
                _roleChip(u.role),
              ],
            ),
          ),

          Row(
            children: [
              _iconAction(
                icon: Icons.edit,
                color: Colors.blue,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdateUserScreen(user: u),
                    ),
                  );
                  if (result == true) _fetchUsers();
                },
              ),
              const SizedBox(width: 8),
              _iconAction(
                icon: Icons.delete,
                color: Colors.red,
                onTap: () => _confirmDelete(u),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ================= FILTER =================

  Widget _filterChips() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == _category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (_) {
                _category = cat;
                _applyFilter();
              },
              backgroundColor: Colors.white,
              selectedColor: primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : primary,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: primary, width: 1.5),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primary,
        title: const Text('Daftar Pengguna'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddUserScreen()),
                );
                if (result == true) _fetchUsers();
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey[400],
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: primary, width: 2),
            ),
            child: TextField(
              onChanged: (v) {
                _search = v;
                _applyFilter();
              },
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: primary),
                hintText: 'Cari pengguna...',
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 10),

          _filterChips(),

          const SizedBox(height: 10),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchUsers,
              child: ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) =>
                    _userCard(_filteredUsers[index]),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar:
          AdminBottomNavbar(currentIndex: 1, onTap: (_) {}),
    );
  }
}
