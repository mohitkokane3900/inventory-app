import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firestore_service.dart';
import 'models/item.dart';
import 'add_edit_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false, home: InventoryHomePage()));
}

class InventoryHomePage extends StatefulWidget {
  const InventoryHomePage({super.key});
  @override
  State<InventoryHomePage> createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  final service = FirestoreService();
  final searchCtl = TextEditingController();
  String query = '';
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    searchCtl.addListener(() {
      setState(() {
        query = searchCtl.text.trim().toLowerCase();
      });
    });
  }

  List<Item> _applyFilters(List<Item> items) {
    List<Item> data = items;
    if (query.isNotEmpty) {
      data = data.where((e) => e.name.toLowerCase().contains(query)).toList();
    }
    if (selectedCategory != 'All') {
      data = data.where((e) => e.category == selectedCategory).toList();
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Management')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: searchCtl,
                decoration: const InputDecoration(
                    labelText: 'Search by name',
                    prefixIcon: Icon(Icons.search))),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Category:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedCategory,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'General', child: Text('General')),
                    DropdownMenuItem(value: 'Food', child: Text('Food')),
                    DropdownMenuItem(
                        value: 'Clothing', child: Text('Clothing')),
                    DropdownMenuItem(
                        value: 'Electronics', child: Text('Electronics')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      selectedCategory = v;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Item>>(
                stream: service.getItemsStream(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Error'));
                  }
                  final items = _applyFilters(snap.data ?? []);
                  if (items.isEmpty) {
                    return const Center(child: Text('No items'));
                  }
                  final totalValue = items.fold<double>(
                      0, (sum, e) => sum + (e.price * e.quantity));
                  return Column(
                    children: [
                      Card(
                        child: ListTile(
                          title: const Text('Dashboard'),
                          subtitle: Text(
                              'Items: ${items.length}    Total Value: \$${totalValue.toStringAsFixed(2)}'),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, i) {
                            final it = items[i];
                            return Card(
                              child: ListTile(
                                title: Text(it.name),
                                subtitle: Text(
                                    'Qty: ${it.quantity}  \$${it.price.toStringAsFixed(2)}  ${it.category}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    if (it.id == null) return;
                                    await service.deleteItem(it.id!);
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              AddEditItemScreen(item: it)));
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddEditItemScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
