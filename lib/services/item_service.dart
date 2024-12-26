import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/item.dart';
import '../model/history.dart';

class ItemService {
  final supabase = Supabase.instance.client;

  Future<Item> createItem(Item item) async {
    final response = await supabase
        .from('items')
        .insert({
      'user_id': supabase.auth.currentUser!.id,
      'name': item.name,
      'photo': item.photo,
      'category': item.category,
      'price': item.price,
      'stock': item.stock,
    })
        .select()
        .single();

    return Item.fromJson(response);
  }

  Future<List<Item>> getItems() async {
    final List<dynamic> response = await supabase
        .from('items')
        .select()
        .eq('user_id', supabase.auth.currentUser!.id);

    return response.map((json) => Item.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> updateItem(Item item) async {
    await supabase
        .from('items')
        .update({
      'name': item.name,
      'photo': item.photo,
      'category': item.category,
      'price': item.price,
      'stock': item.stock,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('id', item.id)
        .eq('user_id', supabase.auth.currentUser!.id);
  }

  Future<void> deleteItem(String id) async {
    await supabase
        .from('item_history')
        .delete()
        .eq('item_id', id)
        .eq('user_id', supabase.auth.currentUser!.id);

    await supabase
        .from('items')
        .delete()
        .eq('id', id)
        .eq('user_id', supabase.auth.currentUser!.id);
  }

  Future<History> createHistory(History history) async {
    final response = await supabase
        .from('item_history')
        .insert({
      'user_id': supabase.auth.currentUser!.id,
      'item_id': history.itemId,
      'item_name': history.itemName,
      'type': history.type,
      'quantity': history.quantity,
      'date': history.date,
    })
        .select()
        .single();

    return History.fromJson(response);
  }

  Future<List<History>> getHistoryForItem(String itemId) async {
    final List<dynamic> response = await supabase
        .from('item_history')
        .select()
        .eq('item_id', itemId)
        .eq('user_id', supabase.auth.currentUser!.id);

    return response.map((json) => History.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> deleteHistory(String historyId) async {
    await supabase
        .from('item_history')
        .delete()
        .eq('id', historyId)
        .eq('user_id', supabase.auth.currentUser!.id);
  }
}