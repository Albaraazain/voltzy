import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/database_provider.dart';
import '../../../core/config/routes.dart';

class ConversationItem extends StatelessWidget {
  final Map<String, dynamic> conversation;
  final VoidCallback onTap;

  const ConversationItem({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                if (conversation['homeowner_id'] != null) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.clientProfileNotes,
                    arguments: {
                      'homeownerId': conversation['homeowner_id'],
                      'professionalId':
                          Provider.of<DatabaseProvider>(context, listen: false)
                              .currentProfessional
                              ?.id,
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Client information not available'),
                    ),
                  );
                }
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.pink[100],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    conversation['client_name']
                            ?.substring(0, 2)
                            .toUpperCase() ??
                        'CL',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.pink[700],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation['client_name'] ?? 'Client',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation['last_message'] ?? 'No messages yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  conversation['time'] ?? '...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                if (conversation['unread_count'] != null &&
                    conversation['unread_count'] > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.pink[400],
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      conversation['unread_count'].toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfessionalMessagesScreen extends StatelessWidget {
  const ProfessionalMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This would normally come from a messages provider
    final List<Map<String, dynamic>> mockConversations = [
      {
        'client_name': 'John Doe',
        'last_message': 'Thanks for the quick response!',
        'time': '10:30 AM',
        'unread_count': 2,
        'homeowner_id': 'john_doe_id',
      },
      {
        'client_name': 'Sarah Smith',
        'last_message': 'When can you come for the repair?',
        'time': 'Yesterday',
        'unread_count': 0,
        'homeowner_id': 'sarah_smith_id',
      },
      {
        'client_name': 'Mike Johnson',
        'last_message': 'Perfect, see you tomorrow!',
        'time': 'Mon',
        'unread_count': 1,
        'homeowner_id': 'mike_johnson_id',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: mockConversations.length,
        itemBuilder: (context, index) {
          return ConversationItem(
            conversation: mockConversations[index],
            onTap: () {
              // TODO: Navigate to conversation detail screen
              print(
                  'Navigate to conversation with ${mockConversations[index]['client_name']}');
            },
          );
        },
      ),
    );
  }
}
