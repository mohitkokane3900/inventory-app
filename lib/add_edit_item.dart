import 'package:flutter/material.dart';
import 'models/item.dart';
import 'services/firestore_service.dart';

class AddEditItemScreen extends StatefulWidget {
  final Item? item;
  const AddEditItemScreen({super.key, this.item});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final service = FirestoreService();
  final nameCtl = TextEditingController();
  final qtyCtl = TextEditingController();
  final priceCtl = TextEditingController();
  final catCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      nameCtl.text = widget.item!.name;
      qtyCtl.text = widget.item!.quantity.toString();
      priceCtl.text = widget.item!.price.toString();
      catCtl.text = widget.item!.category;
    }
  }

  Future<void> _save() async {
    final n = nameCtl.text.trim();
    final q = int.tryParse(qtyCtl.text.trim());
    final p = double.tryParse(priceCtl.text.trim());
    final c = catCtl.text.trim();
    if (n.isEmpty || q == null || p == null || c.isEmpty) return;
    final item = Item(
      id: widget.item?.id,
      name: n,
      quantity: q,
      price: p,
      category: c,
      createdAt: DateTime.now(),
    );
    if (widget.item == null) {
      await service.addItem(item);
    } else {
      await service.updateItem(item);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (widget.item == null) return;
    await service.deleteItem(widget.item!.id!);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Item' : 'Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
                controller: nameCtl,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: qtyCtl,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number),
            TextField(
                controller: priceCtl,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true)),
            TextField(
                controller: catCtl,
                decoration: const InputDecoration(labelText: 'Category')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _save, child: const Text('Save')),
            if (isEdit)
              TextButton(
                  onPressed: _delete,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete')),
          ],
        ),
      ),
    );
  }
}
