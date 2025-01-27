import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/base_service_model.dart';
import '../../../providers/database_provider.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/widgets/loading_overlay.dart';
import 'broadcast_request_map_screen.dart';

class BroadcastJobScreen extends StatefulWidget {
  final BaseService service;

  const BroadcastJobScreen({
    super.key,
    required this.service,
  });

  @override
  State<BroadcastJobScreen> createState() => _BroadcastJobScreenState();
}

class _BroadcastJobScreenState extends State<BroadcastJobScreen> {
  int _selectedHours = 2;
  double _selectedBudget = 100;
  final TextEditingController _descriptionController = TextEditingController();
  final List<int> _hourOptions = [1, 2, 3, 4];
  List<double> _budgetOptions = [75, 100, 125, 150];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize budget options based on service price
    _selectedBudget = widget.service.basePrice;
    _budgetOptions = [
      widget.service.basePrice * 0.75,
      widget.service.basePrice,
      widget.service.basePrice * 1.25,
      widget.service.basePrice * 1.5,
    ];
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _proceedToMap() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add a description of your request')),
      );
      return;
    }

    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    final homeowner = databaseProvider.currentHomeowner;

    if (homeowner?.locationLat == null || homeowner?.locationLng == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please set your location before proceeding')),
        );
      }
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BroadcastRequestMapScreen(
          service: widget.service,
          initialLat: homeowner!.locationLat!,
          initialLng: homeowner.locationLng!,
          hours: _selectedHours,
          budget: _selectedBudget,
          description: _descriptionController.text,
        ),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true); // Return success to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildDurationSelector(),
                      const SizedBox(height: 24),
                      _buildBudgetSelector(),
                      const SizedBox(height: 24),
                      _buildDescriptionInput(),
                      const SizedBox(height: 24),
                      _buildTotalCost(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.chevron_left),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 2,
                  width: 24,
                  color: Colors.grey.shade800,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.service.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '\$${widget.service.basePrice}/hr',
                style: TextStyle(
                  color: Colors.amber.shade700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Available Now',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Service Duration',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'How many hours needed?',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Icon(Icons.schedule, color: Colors.pink.shade500),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: _hourOptions.map((hours) {
              final isSelected = _selectedHours == hours;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () => setState(() => _selectedHours = hours),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? Colors.pink.shade500
                          : Colors.white.withOpacity(0.5),
                      foregroundColor:
                          isSelected ? Colors.white : Colors.grey.shade600,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('${hours}h'),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Budget per Hour',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select your budget range',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Icon(Icons.attach_money, color: Colors.amber.shade500),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: _budgetOptions.map((budget) {
              final isSelected = _selectedBudget == budget;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () => setState(() => _selectedBudget = budget),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? Colors.amber.shade500
                          : Colors.white.withOpacity(0.5),
                      foregroundColor:
                          isSelected ? Colors.white : Colors.grey.shade600,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('\$${budget.toInt()}'),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Job Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Describe what you need help with',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Icon(Icons.description, color: Colors.green.shade500),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter job description...',
              filled: true,
              fillColor: Colors.white.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCost() {
    final totalCost = _selectedHours * _selectedBudget;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Cost',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'For $_selectedHours hours of service',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Text(
            '\$${totalCost.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _proceedToMap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Continue to Map',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
