import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../services/item_service.dart';
import '../services/supplier_service.dart';
import 'login_page.dart';
import 'supplier_list_page.dart';
import 'item_list_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _supplierService = SupplierService();
  final _itemService = ItemService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _supplierCount = '0';
  String _itemCount = '0';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    await Future.wait([
      _loadSupplierCount(),
      _loadItemCount(),
    ]);
  }

  Future<void> _loadSupplierCount() async {
    try {
      final suppliers = await _supplierService.getSuppliers();
      if (mounted) {
        setState(() {
          _supplierCount = suppliers.length.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data supplier')),
        );
      }
    }
  }

  Future<void> _loadItemCount() async {
    try {
      final items = await _itemService.getItems();
      if (mounted) {
        setState(() {
          _itemCount = items.length.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data barang')),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDashboardCard(
                  title: 'Total Barang',
                  value: _itemCount,
                  icon: Icons.inventory,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ItemListPage(),
                      ),
                    ).then((_) => _loadItemCount());
                  },
                ),
                const SizedBox(height: 16),
                _buildDashboardCard(
                  title: 'Total Supplier',
                  value: _supplierCount,
                  icon: Icons.people,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SupplierListPage(),
                      ),
                    ).then((_) => _loadSupplierCount());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 48, color: Colors.deepOrange),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}