import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/supplier.dart';

class SupplierService {
  final supabase = Supabase.instance.client;

  Future<Supplier> createSupplier(Supplier supplier) async {
    final response = await supabase
        .from('suppliers')
        .insert(supplier.toJson())
        .select()
        .single();

    return Supplier.fromJson(response);
  }

  Future<List<Supplier>> getSuppliers() async {
    final List<dynamic> response = await supabase
        .from('suppliers')
        .select();

    return response.map((json) => Supplier.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> deleteSupplier(String id) async {
    await supabase
        .from('suppliers')
        .delete()
        .eq('id', id);
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await supabase
        .from('suppliers')
        .update(supplier.toJson())
        .eq('id', supplier.id!);
  }
}