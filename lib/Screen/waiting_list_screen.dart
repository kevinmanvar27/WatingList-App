import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'App_State.dart';
import 'models/restaurant.dart';
import 'models/waiting_person.dart';

class WaitingListScreen extends StatelessWidget {
  final Restaurant restaurant;
  const WaitingListScreen({required this.restaurant, super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<WaitingPerson>>(
        future: appState.database.getWaitingForRestaurant(restaurant.id!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final waiting = snapshot.data!;
          if (waiting.isEmpty) {
            return const Center(child: Text('No one is waiting yet'));
          }

          return ListView.builder(
            itemCount: waiting.length,
            itemBuilder: (context, i) {
              final w = waiting[i];
              return ListTile(
                title: Text(w.name),
                subtitle: Text('Party: ${w.partySize}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPersonDialog(context),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _addPersonDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final nameCtrl = TextEditingController();
    final partyCtrl = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Person to ${restaurant.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: partyCtrl,
              decoration: const InputDecoration(labelText: 'Party size'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final party = int.tryParse(partyCtrl.text) ?? 1;
              if (name.isNotEmpty) {
                await appState.addPerson(restaurant.id!, name, party);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
