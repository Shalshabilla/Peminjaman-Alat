import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_services.dart';
import 'create_user_screen.dart';
import 'update_user_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  late TabController _tabController;
  List<AppUser> _allUsers = [];
  List<AppUser> _filteredUsers = [];
  String _searchQuery = '';
  String _currentTab = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    _allUsers = await _userService.getAllUsers();
    _filterUsers();
    setState(() {});
  }

  void _handleTabChange() {
    final tabs = ['Semua', 'Admin', 'Petugas', 'Siswa'];
    _currentTab = tabs[_tabController.index];
    _filterUsers();
  }

  void _filterUsers() {
    if (_currentTab == 'Semua') {
      _filteredUsers = _allUsers;
    } else {
      _filteredUsers = _allUsers.where((user) => user.role == _currentTab).toList();
    }
    if (_searchQuery.isNotEmpty) {
      _filteredUsers = _filteredUsers.where((user) =>
          user.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    setState(() {});
  }

  void _showDeleteDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            const Text('Hapus Pengguna', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Anda yakin ingin menghapus pengguna?'),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _userService.deleteUser(user.id);
                  Navigator.pop(context);
                  _fetchUsers();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengguna dihapus')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text('Daftar Pengguna', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Color(0xFFBDBDBD),
              child: Icon(Icons.person_add, color: Colors.white),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddUserScreen())).then((_) => _fetchUsers()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                _searchQuery = value;
                _filterUsers();
              },
              decoration: InputDecoration(
                hintText: 'Cari pengguna...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF3F51B5),
            tabs: const [
              Tab(text: 'Semua'),
              Tab(text: 'Admin'),
              Tab(text: 'Petugas'),
              Tab(text: 'Siswa'),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchUsers,
              child: ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFBDBDBD),
                          child: Text(user.nama[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(user.email, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF2196F3)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(user.role),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => UpdateUserScreen(user: user)),
                          ).then((_) => _fetchUsers()),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(user),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF3F51B5),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.layers), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}