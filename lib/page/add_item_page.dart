import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/item_service.dart';
import '../model/item.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String _photo = '';
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final ItemService _itemService = ItemService();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024, // Limit image size
        maxHeight: 1024,
        imageQuality: 85, // Compress image
      );
      if (pickedFile != null) {
        final imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _photo = base64Encode(imageBytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil gambar')),
      );
    }
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        Item newItem = Item(
          name: _nameController.text,
          photo: _photo,
          category: _categoryController.text,
          price: int.parse(_priceController.text),
          stock: int.parse(_stockController.text),
        );

        await _itemService.createItem(newItem);

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyimpan barang')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pilih sumber gambar"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text("Galeri"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(source: ImageSource.gallery);
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text("Kamera"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(source: ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text('Tambah Barang Baru',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      image: _photo.isNotEmpty
                          ? DecorationImage(
                        image: MemoryImage(base64Decode(_photo)),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _photo.isEmpty
                        ? const Icon(Icons.camera_alt, size: 60)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Barang'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama barang tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kategori tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(labelText: 'Stok'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Stok tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveItem,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepOrange,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}