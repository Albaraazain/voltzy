import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  (Color, Color) getStatusColors() {
    switch (status) {
      case 'In Progress':
        return (Colors.pink.shade100, Colors.pink.shade700);
      case 'Scheduled':
        return (Colors.amber.shade100, Colors.amber.shade700);
      default:
        return (Colors.grey.shade100, Colors.grey.shade600);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = getStatusColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 14,
          color: textColor,
        ),
      ),
    );
  }
}

class ProfessionalJobDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const ProfessionalJobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  State<ProfessionalJobDetailsScreen> createState() =>
      _ProfessionalJobDetailsScreenState();
}

class _ProfessionalJobDetailsScreenState
    extends State<ProfessionalJobDetailsScreen> {
  void _navigateToClientNotes() {
    if (widget.job['homeowner'] != null) {
      Navigator.pushNamed(
        context,
        '/professional/client-notes',
        arguments: widget.job['homeowner'],
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client information not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add),
            onPressed: _navigateToClientNotes,
            tooltip: 'Client Notes',
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.chevron_left, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 24,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.job['service_type'] ??
                                  'Electrical Installation',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            StatusBadge(
                                status: widget.job['status'] ?? 'In Progress'),
                          ],
                        ),
                        FloatingActionButton(
                          onPressed: () {
                            // TODO: Handle phone call
                          },
                          backgroundColor: Colors.pink[500],
                          child: const Icon(Icons.phone, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Client Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _navigateToClientNotes,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.amber[100],
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.job['client_initials'] ?? 'SJ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber[700],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.job['client_name'] ??
                                        'Sarah Johnson',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.star,
                                          size: 16, color: Colors.amber[500]),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.job['client_rating'] ?? '4.9'} (${widget.job['client_jobs'] ?? '24'} jobs)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.job['address'] ??
                                      '123 Main St, Boston, MA 02108',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.schedule,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                widget.job['scheduled_time'] ??
                                    'Today, 09:00 AM - 11:00 AM',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Job Details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Job Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                              'Service Type',
                              widget.job['service_type'] ??
                                  'Electrical Installation'),
                          _buildDetailRow(
                              'Rate', '\$${widget.job['rate'] ?? '85'}/hour'),
                          _buildDetailRow('Estimated Duration',
                              widget.job['duration'] ?? '2-3 hours'),
                          _buildDetailRow('Payment Method',
                              widget.job['payment_method'] ?? 'Credit Card',
                              showBorder: false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Requirements & Notes
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Requirements & Notes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.job['notes'] ??
                                'Need to install new outlets in home office. Total of 4 outlets needed. Building is pre-1990s, so might need wiring update. Please bring necessary tools and materials.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final tag
                                  in (widget.job['tags'] as List<String>? ??
                                      [
                                        '4 Outlets',
                                        'Home Office',
                                        'Wiring Update'
                                      ]))
                                _buildTag(tag),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.camera_alt,
                            label: 'Take Photos',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.note_add,
                            label: 'Add Notes',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100), // Space for bottom buttons
                  ],
                ),
              ),
            ),
            // Complete Job Button
            Positioned(
              bottom: 20,
              left: 24,
              right: 24,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Handle job completion
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[500],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Complete Job',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool showBorder = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                ),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton(
      onPressed: () {
        // TODO: Handle button action
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.grey[600],
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
