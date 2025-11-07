import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class FirestoreService {
  final CollectionReference<Map<String, dynamic>> col =
      FirebaseFirestore.instance.collection('items');

  Future<void> addItem(Item item) async {
    await col.add(item.toMap());
  }

  Stream<List<Item>> getItemsStream() {
    return col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Item.fromMap(d.id, d.data())).toList());
  }

  Future<void> updateItem(Item item) async {
    if (item.id == null) return;
    await col.doc(item.id).update(item.toMap());
  }

  Future<void> deleteItem(String id) async {
    await col.doc(id).delete();
  }
}
