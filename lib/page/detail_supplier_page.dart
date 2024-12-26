import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/supplier.dart';

class DetailSupplierPage extends StatefulWidget {
  final Supplier supplier;

  const DetailSupplierPage({
    super.key,
    required this.supplier,
  });

  @override
  State<DetailSupplierPage> createState() => _DetailSupplierPageState();
}

class _DetailSupplierPageState extends State<DetailSupplierPage> {
  late GoogleMapController _mapController;
  late Set<Marker> _markers;

  @override
  void initState() {
    super.initState();
    _markers = {
      Marker(
        markerId: const MarkerId('supplierLocation'),
        position: LatLng(widget.supplier.latitude, widget.supplier.longitude),
        infoWindow: InfoWindow(
          title: widget.supplier.name,
          snippet: widget.supplier.address,
        ),
      ),
    };
  }

  Future<void> _openInMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${widget.supplier.latitude},${widget.supplier.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka peta')),
        );
      }
    }
  }

  Future<void> _makePhoneCall() async {
    final url = 'tel:${widget.supplier.contact}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat melakukan panggilan')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
            'Detail Supplier',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
            )
        ),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildMapCard(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.supplier.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              title: 'Alamat',
              value: widget.supplier.address,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.phone_outlined,
              title: 'Kontak',
              value: widget.supplier.contact,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.gps_fixed,
              title: 'Koordinat',
              value: '${widget.supplier.latitude}, ${widget.supplier.longitude}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 200,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.supplier.latitude, widget.supplier.longitude),
              zoom: 15,
            ),
            markers: _markers,
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _makePhoneCall,
            icon: const Icon(Icons.phone),
            label: const Text('Hubungi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _openInMaps,
            icon: const Icon(Icons.map),
            label: const Text('Buka Maps'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}