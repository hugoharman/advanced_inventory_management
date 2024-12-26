import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/supplier.dart';
import '../services/supplier_service.dart';

class AddSupplierPage extends StatefulWidget {
  const AddSupplierPage({super.key});

  @override
  State<AddSupplierPage> createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends State<AddSupplierPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();

  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _isLoadingAddress = false;
  String _currentAddress = '';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  final _supplierService = SupplierService();

  Future<void> _saveSupplier() async {
    if (_formKey.currentState!.validate() && _selectedLocation != null) {
      try {
        setState(() => _isLoading = true);

        final supplier = Supplier(
          name: _nameController.text,
          address: _addressController.text,
          contact: _contactController.text,
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          userId: Supabase.instance.client.auth.currentUser!.id,
        );

        await _supplierService.createSupplier(supplier);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Supplier berhasil ditambahkan')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
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
    } else if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih lokasi supplier')),
      );
    }
  }
  Future<void> _initializeLocation() async {
    try {
      setState(() => _isLoading = true);

      // Check location service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _currentAddress = 'Layanan lokasi tidak aktif');
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _currentAddress = 'Izin lokasi ditolak');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _currentAddress = 'Izin lokasi ditolak permanen');
        return;
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      final latLng = LatLng(position.latitude, position.longitude);
      await _updateMarkerAndCamera(latLng);

    } catch (e) {
      print('Error in initialization: $e');
      // Default to Jakarta if error
      await _updateMarkerAndCamera(const LatLng(-6.200000, 106.816666));
    } finally {
      setState(() => _isLoading = false);
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
        print('Placemark: $place'); // For debugging

        final addressParts = [
          place.thoroughfare,        // Jalan
          place.subLocality,        // Kelurahan
          place.locality,           // Kecamatan
          place.subAdministrativeArea, // Kota
          place.administrativeArea, // Provinsi
          place.postalCode,        // Kode Pos
        ].where((part) => part != null && part.isNotEmpty).toList();

        final address = addressParts.join(', ');

        print('Generated Address: $address'); // For debugging

        if (address.isNotEmpty) {
          setState(() {
            _currentAddress = address;
            _addressController.text = address;
          });
        } else {
          setState(() => _currentAddress = 'Alamat tidak ditemukan');
        }
      } else {
        setState(() => _currentAddress = 'Alamat tidak ditemukan');
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() => _currentAddress = 'Tidak dapat memuat alamat');
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    try {
      setState(() => _mapController = controller);
      if (_selectedLocation != null) {
        _getAddressFromLatLng(_selectedLocation!);
      }
    } catch (e) {
      print('Error creating map: $e');
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
          infoWindow: InfoWindow(
            title: 'Lokasi Supplier',
            snippet: _currentAddress.isNotEmpty ? _currentAddress : null,
          ),
        ),
      };
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(latLng, 15),
    );

    await _getAddressFromLatLng(latLng);
  }

  void _onMapTapped(LatLng latLng) {
    _updateMarkerAndCamera(latLng);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
            'Tambah Supplier',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
            )
        ),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMapSection(),
              const SizedBox(height: 24),
              _buildInputFields(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 300,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation ?? const LatLng(-6.200000, 106.816666),
                      zoom: 15,
                    ),
                    onMapCreated: _onMapCreated,
                    markers: _markers,
                    onTap: _onMapTapped,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    mapToolbarEnabled: true,
                    compassEnabled: true,
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: 'centerMap',
                      backgroundColor: Colors.white,
                      mini: true,
                      child: const Icon(Icons.center_focus_strong, color: Colors.deepOrange),
                      onPressed: () async {
                        if (_selectedLocation != null) {
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (_selectedLocation != null)
                  Text(
                    'Koordinat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                        '${_selectedLocation!.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.deepOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (_isLoadingAddress)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                  )
                else if (_currentAddress.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _currentAddress,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Nama Supplier',
          icon: Icons.business,
          validator: (value) => value?.isEmpty ?? true ? 'Silakan masukkan nama supplier' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: 'Alamat',
          icon: Icons.location_on,
          maxLines: 3,
          validator: (value) => value?.isEmpty ?? true ? 'Silakan masukkan alamat' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _contactController,
          label: 'Kontak',
          icon: Icons.phone,
          validator: (value) => value?.isEmpty ?? true ? 'Silakan masukkan kontak' : null,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.deepOrange),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveSupplier,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: _isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : const Text(
        'Simpan',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}