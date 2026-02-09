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

  final List<String> categories = ['Semua', 'Admin', 'Petugas', 'Peminjam'];

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
    _filteredUsers = _allUsers.where((u) {
      final matchSearch = u.nama.toLowerCase().contains(_search.toLowerCase()) ||
          u.email.toLowerCase().contains(_search.toLowerCase());

      final matchCategory =
          _category == 'Semua' || u.role == _category;

      return matchSearch && matchCategory;
    }).toList();

    setState(() {});
  }

  void _confirmDelete(AppUser user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.red, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Hapus Pengguna',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Anda yakin ingin menghapus pengguna?'),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () async {
              await _service.deleteUser(user.id);
              Navigator.pop(context);
              _fetchUsers();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2F345D),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Color(0xFF2F345D),
              child: Icon(Icons.person_add, color: Colors.white),
            ),
           onPressed: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const AddUserScreen(),
    ),
  );

  if (result == true) {
    _fetchUsers(); 
  }
},

          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) {
                _search = v;
                _applyFilter();
              },
              decoration: InputDecoration(
                hintText: 'Cari pengguna...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🏷️ CATEGORY
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: categories.map((c) {
                final active = _category == c;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: active,
                    selectedColor: const Color(0xFF2F345D),
                    labelStyle: TextStyle(
                      color: active ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      _category = c;
                      _applyFilter();
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // 👥 USER LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredUsers.length,
              itemBuilder: (_, i) {
                final u = _filteredUsers[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFE3E6F3),
                        child: Text(
                          u.nama[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF2F345D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              u.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              u.email,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Color(0xFF2196F3)),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                UpdateUserScreen(user: u),
                          ),
                        ).then((_) => _fetchUsers()),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(u),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 1,
        onTap: (_) {},
      ),
    );
  }
}
