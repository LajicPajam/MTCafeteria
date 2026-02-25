import 'package:flutter/material.dart';

import '../models/landing_item.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({
    super.key,
    required this.items,
    required this.canManage,
    required this.onCreate,
    required this.onUpdate,
    required this.onDelete,
  });

  final List<LandingItem> items;
  final bool canManage;
  final Future<void> Function(Map<String, dynamic>) onCreate;
  final Future<void> Function(int id, Map<String, dynamic>) onUpdate;
  final Future<void> Function(int id) onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Landing Page Hub',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              if (canManage)
                ElevatedButton.icon(
                  onPressed: () =>
                      _showLandingDialog(context, onSave: onCreate),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Announcements, reminders, upcoming activities, and VIP event notices.',
          ),
          const SizedBox(height: 14),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No landing items yet.'))
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, separatorIndex) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        child: ListTile(
                          title: Text('${item.type}: ${item.title}'),
                          subtitle: Text(
                            '${item.content}\n${item.startDate} - ${item.endDate}',
                          ),
                          isThreeLine: true,
                          trailing: canManage
                              ? Wrap(
                                  spacing: 8,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () => _showLandingDialog(
                                        context,
                                        existing: item,
                                        onSave: (payload) =>
                                            onUpdate(item.id, payload),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => onDelete(item.id),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLandingDialog(
    BuildContext context, {
    LandingItem? existing,
    required Future<void> Function(Map<String, dynamic>) onSave,
  }) async {
    final typeController = TextEditingController(
      text: existing?.type ?? 'Announcement',
    );
    final titleController = TextEditingController(text: existing?.title ?? '');
    final contentController = TextEditingController(
      text: existing?.content ?? '',
    );
    final startDateController = TextEditingController(
      text:
          existing?.startDate ??
          DateTime.now().toIso8601String().split('T').first,
    );
    final endDateController = TextEditingController(
      text:
          existing?.endDate ??
          DateTime.now().toIso8601String().split('T').first,
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          existing == null ? 'Add Landing Item' : 'Edit Landing Item',
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
              TextField(
                controller: startDateController,
                decoration: const InputDecoration(
                  labelText: 'Start Date (YYYY-MM-DD)',
                ),
              ),
              TextField(
                controller: endDateController,
                decoration: const InputDecoration(
                  labelText: 'End Date (YYYY-MM-DD)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final payload = {
                'type': typeController.text.trim(),
                'title': titleController.text.trim(),
                'content': contentController.text.trim(),
                'startDate': startDateController.text.trim(),
                'endDate': endDateController.text.trim(),
              };
              await onSave(payload);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    typeController.dispose();
    titleController.dispose();
    contentController.dispose();
    startDateController.dispose();
    endDateController.dispose();
  }
}
