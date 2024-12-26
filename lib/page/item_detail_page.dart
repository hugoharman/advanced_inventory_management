import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/item_service.dart';
import '../model/item.dart';
import '../model/history.dart';
import 'history_page.dart';

class ItemDetailPage extends StatefulWidget {
  const ItemDetailPage({super.key, required this.item});

  final Item item;

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final ItemService _itemService = ItemService();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late String _photo;
  List<History> _history = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _categoryController = TextEditingController(text: widget.item.category);
    _priceController = TextEditingController(text: widget.item.price.toString());
    _stockController = TextEditingController(text: widget.item.stock.toString());
    _photo = widget.item.photo;
    _loadHistory();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _photo = base64Encode(imageBytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _updateItem() async {
    try {
      Item updatedItem = Item(
        id: widget.item.id,
        name: _nameController.text,
        photo: _photo,
        category: _categoryController.text,
        price: int.parse(_priceController.text),
        stock: int.parse(_stockController.text),
      );

      await _itemService.updateItem(updatedItem);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating item: $e')),
      );
    }
  }

  Future<void> _deleteItem() async {
    try {
      await _itemService.deleteItem(widget.item.id!);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item: $e')),
      );
    }
  }

  Future<void> _loadHistory() async {
    try {
      List<History> history = await _itemService.getHistoryForItem(widget.item.id!);
      setState(() {
        _history = history;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading history: $e')),
      );
    }
  }

  Future<void> _deleteHistory(History history) async {
    try {
      bool? shouldDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Hapus Riwayat'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Apakah Anda yakin ingin menghapus riwayat ini?'),
                SizedBox(height: 16),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Hapus'),
                onPressed: () async {
                  // Update item stock
                  int stockChange = history.type == 'Masuk' ? -history.quantity : history.quantity;
                  widget.item.stock += stockChange;

                  // Update the item and delete history
                  await _itemService.updateItem(widget.item);
                  await _itemService.deleteHistory(history.id!);

                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      if (shouldDelete == true) {
        await _loadHistory();
        await _loadItems();
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting history: $e')),
      );
    }
  }

  Future<void> _loadItems() async {
    try {
      List<Item> items = await _itemService.getItems();
      setState(() {
        // Update the current item's stock if it exists in the list
        final updatedItem = items.firstWhere((item) => item.id == widget.item.id);
        _stockController.text = updatedItem.stock.toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading items: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (_photo.isNotEmpty) {
      imageBytes = base64Decode(_photo);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(
          widget.item.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Detail Barang'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Nama: ${_nameController.text}'),
                      Text('Kategori: ${_categoryController.text}'),
                      Text('Harga: ${_priceController.text}'),
                      Text('Stok: ${_stockController.text}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup', style: TextStyle(color: Colors.deepOrange)),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi'),
                  content: const Text('Apakah Anda yakin ingin menghapus barang ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal', style: TextStyle(color: Colors.deepOrange)),
                    ),
                    TextButton(
                      onPressed: () {
                        _deleteItem();
                        Navigator.pop(context);
                      },
                      child: const Text('Hapus', style: TextStyle(color: Colors.deepOrange)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Hero(
                  tag: 'itemImage-${widget.item.name}',
                  child: Center(
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: imageBytes != null
                            ? DecorationImage(
                          image: MemoryImage(imageBytes),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: imageBytes == null
                          ? const Icon(Icons.camera_alt, size: 60)
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Barang'),
              ),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _updateItem,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepOrange,
                  ),
                  child: const Text('Update'),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryPage(item: widget.item),
                      ),
                    ).then((value) {
                      if (value == true) {
                        _loadHistory();
                        _loadItems();
                        setState(() {
                          widget.item.stock = int.parse(_stockController.text);
                        });
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepOrange,
                  ),
                  child: const Text('Tambah Riwayat'),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Riwayat Barang',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              _history.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Tidak ada riwayat barang.'),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final history = _history[index];
                  return ListTile(
                    title: Text('${history.type} (${history.quantity}) - ${history.itemName}'),
                    subtitle: Text(
                      'Tanggal: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(history.date))}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteHistory(history),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}