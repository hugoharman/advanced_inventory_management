import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../model/supplier.dart';
import '../services/supplier_service.dart';
import 'add_supplier_page.dart';
import 'detail_supplier_page.dart';

class SupplierListPage extends StatefulWidget {
  const SupplierListPage({super.key});

  @override
  State<SupplierListPage> createState() => _SupplierListPageState();
}

class _SupplierListPageState extends State<SupplierListPage> {
  final _supplierService = SupplierService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isLoadingAddress = false;
  List<Supplier> _suppliers = [];

  // Controllers for editing
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;

  // Map related variables
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  Set<Marker> _markers = {};
  String _currentAddress = '';

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _contactController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadSuppliers() async {
    try {
      setState(() => _isLoading = true);
      final suppliers = await _supplierService.getSuppliers();
      setState(() => _suppliers = suppliers);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteSupplier(Supplier supplier) async {
    try {
      await _supplierService.deleteSupplier(supplier.id!);
      await _loadSuppliers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supplier berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _updateSupplier(Supplier supplier) async {
    try {
      if (_selectedLocation == null) {
        _selectedLocation = LatLng(supplier.latitude, supplier.longitude);
      }

      final updatedSupplier = Supplier(
        id: supplier.id,
        name: _nameController.text,
        address: _addressController.text,
        contact: _contactController.text,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        userId: supplier.userId,
      );

      await _supplierService.updateSupplier(updatedSupplier);
      await _loadSuppliers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supplier berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() => _isLoadingAddress = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final addressParts = [
          place.thoroughfare,
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.postalCode,
        ].where((part) => part != null && part.isNotEmpty).toList();

        final address = addressParts.join(', ');

        setState(() {
          _currentAddress = address;
          _addressController.text = address;
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  Future<void> _updateMarkerAndCamera(LatLng latLng) async {
    setState(() {
      _selectedLocation = latLng;
      _markers = {
        Marker(
          markerId: const MarkerId('selectedLocation'),
          position: latLng,
          draggable: true,
          onDragEnd: (newPosition) async {
            setState(() => _selectedLocation = newPosition);
            await _getAddressFromLatLng(newPosition);
          },
        ),
      };
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(latLng, 15),
    );

    await _getAddressFromLatLng(latLng);
  }

  void _showUpdateDialog(Supplier supplier) {
    _nameController.text = supplier.name;
    _addressController.text = supplier.address;
    _contactController.text = supplier.contact;
    _selectedLocation = LatLng(supplier.latitude, supplier.longitude);

    // Initialize markers
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selectedLocation'),
          position: _selectedLocation!,
          draggable: true,
          onDragEnd: (newPosition) async {
            await _updateMarkerAndCamera(newPosition);
          },
        ),
      };
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // Add StatefulBuilder
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Update Supplier'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _selectedLocation!,
                              zoom: 15,
                            ),
                            onMapCreated: (controller) => _mapController = controller,
                            markers: _markers,
                            onTap: (latLng) async {
                              await _updateMarkerAndCamera(latLng);
                              setDialogState(() {}); // Update dialog state
                            },
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoadingAddress)
                        const CircularProgressIndicator(color: Colors.deepOrange)
                      else if (_currentAddress.isNotEmpty)
                        Text(_currentAddress),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nama'),
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Nama tidak boleh kosong' : null,
                      ),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Alamat'),
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Alamat tidak boleh kosong' : null,
                      ),
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(labelText: 'Kontak'),
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Kontak tidak boleh kosong' : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    Navigator.pop(context);
                    _updateSupplier(supplier);
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }
  Widget _buildSupplierCard(Supplier supplier) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailSupplierPage(supplier: supplier),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      supplier.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Replace PopupMenuButton with direct action buttons
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        onPressed: () => _showUpdateDialog(supplier),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Supplier'),
                              content: Text(
                                  'Apakah Anda yakin ingin menghapus supplier ${supplier.name}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteSupplier(supplier);
                                  },
                                  child: const Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        tooltip: 'Hapus',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      supplier.address,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    supplier.contact,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Daftar Supplier',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSupplierPage()),
          );

          if (result == true) {
            await _loadSuppliers();
          }
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : RefreshIndicator(
        onRefresh: _loadSuppliers,
        color: Colors.deepOrange,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _suppliers.length,
          itemBuilder: (context, index) =>
              _buildSupplierCard(_suppliers[index]),
        ),
      ),
    );
  }
}