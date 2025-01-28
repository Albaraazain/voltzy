import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/homeowner_model.dart';
import '../../../models/client_note_model.dart';
import '../../../models/client_service_history_model.dart';
import '../../../providers/client_notes_provider.dart';
import '../widgets/add_client_note_dialog.dart';
import '../../../providers/database_provider.dart';

class NoteCard extends StatelessWidget {
  final ClientNote note;

  const NoteCard({super.key, required this.note});

  Color _getCategoryColor() {
    switch (note.category) {
      case 'Important':
        return Colors.pink.shade100;
      case 'Preference':
        return Colors.blue.shade100;
      case 'Access':
        return Colors.amber.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getCategoryTextColor() {
    switch (note.category) {
      case 'Important':
        return Colors.pink.shade600;
      case 'Preference':
        return Colors.blue.shade600;
      case 'Access':
        return Colors.amber.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(note.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getCategoryColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  note.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getCategoryTextColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note.content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceHistoryItem extends StatelessWidget {
  final ClientServiceHistory service;

  const ServiceHistoryItem({super.key, required this.service});

  Color _getStatusColor() {
    switch (service.status) {
      case 'Completed':
        return Colors.green.shade500;
      case 'Scheduled':
        return Colors.blue.shade500;
      case 'In Progress':
        return Colors.amber.shade500;
      default:
        return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.settings,
              size: 20,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.serviceName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(service.serviceDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${service.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                service.status,
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatusColor(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ClientProfileNotesScreen extends StatefulWidget {
  final Homeowner homeowner;

  const ClientProfileNotesScreen({
    super.key,
    required this.homeowner,
  });

  @override
  State<ClientProfileNotesScreen> createState() =>
      _ClientProfileNotesScreenState();
}

class _ClientProfileNotesScreenState extends State<ClientProfileNotesScreen> {
  late String _professionalId;

  @override
  void initState() {
    super.initState();
    _professionalId =
        context.read<DatabaseProvider>().currentProfessional?.id ?? '';
    if (_professionalId.isEmpty) {
      // Handle error - professional not found
      return;
    }

    // Load data when screen initializes
    final provider = context.read<ClientNotesProvider>();
    provider.loadClientNotes(widget.homeowner.id, _professionalId);
    provider.loadServiceHistory(widget.homeowner.id, _professionalId);
  }

  void _showAddNoteDialog() {
    if (_professionalId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Professional ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddClientNoteDialog(
        homeownerId: widget.homeowner.id,
        professionalId: _professionalId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        width: 24,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // TODO: Implement edit functionality
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Profile Info
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.homeowner.profile.name
                            .substring(0, 2)
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade700,
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
                          widget.homeowner.profile.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Premium Client',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Contact Info
              Column(
                children: [
                  _buildContactItem(
                    Icons.location_on,
                    widget.homeowner.address ?? 'No address provided',
                  ),
                  const SizedBox(height: 8),
                  _buildContactItem(
                    Icons.phone,
                    widget.homeowner.phone ?? 'No phone provided',
                  ),
                  const SizedBox(height: 8),
                  _buildContactItem(
                    Icons.email,
                    widget.homeowner.profile.email,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      Icons.message,
                      'Message',
                      () {
                        // TODO: Implement message action
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      Icons.calendar_today,
                      'Schedule',
                      () {
                        // TODO: Implement schedule action
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      Icons.warning,
                      'Report',
                      () {
                        // TODO: Implement report action
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notes Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Client Notes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showAddNoteDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Note'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.pink.shade50,
                      foregroundColor: Colors.pink.shade600,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Consumer<ClientNotesProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.notes.isEmpty) {
                    return Center(
                      child: Text(
                        'No notes yet',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: provider.notes
                        .map((note) => NoteCard(note: note))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Service History
              const Text(
                'Service History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              Consumer<ClientNotesProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.serviceHistory.isEmpty) {
                    return Center(
                      child: Text(
                        'No service history yet',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: provider.serviceHistory
                        .map((service) => ServiceHistoryItem(service: service))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Next Appointment
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Next Appointment',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement view all appointments
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: Colors.pink.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Circuit Repair',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Feb 02, 2025 - 10:00 AM',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
