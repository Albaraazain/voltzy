import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import 'search_filter_chip.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, List<String>> filterGroups;
  final Map<String, List<String>> selectedFilters;
  final Function(Map<String, List<String>>) onApply;
  final VoidCallback onReset;

  const FilterBottomSheet({
    super.key,
    required this.filterGroups,
    required this.selectedFilters,
    required this.onApply,
    required this.onReset,
  });

  static Future<void> show({
    required BuildContext context,
    required Map<String, List<String>> filterGroups,
    required Map<String, List<String>> selectedFilters,
    required Function(Map<String, List<String>>) onApply,
    required VoidCallback onReset,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        filterGroups: filterGroups,
        selectedFilters: selectedFilters,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, List<String>> _selectedFilters;

  @override
  void initState() {
    super.initState();
    _selectedFilters = Map.from(widget.selectedFilters);
  }

  void _toggleFilter(String group, String value) {
    setState(() {
      if (_selectedFilters[group]?.contains(value) ?? false) {
        _selectedFilters[group]?.remove(value);
        if (_selectedFilters[group]?.isEmpty ?? false) {
          _selectedFilters.remove(group);
        }
      } else {
        _selectedFilters.putIfAbsent(group, () => []).add(value);
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedFilters.clear();
    });
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: AppTextStyles.h3,
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Reset',
                    style: AppTextStyles.link.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.filterGroups.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        entry.key,
                        style: AppTextStyles.subtitle1,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: entry.value.map((value) {
                          final isSelected =
                              _selectedFilters[entry.key]?.contains(value) ??
                                  false;
                          return SearchFilterChip(
                            label: value,
                            isSelected: isSelected,
                            onTap: () => _toggleFilter(entry.key, value),
                            showRemoveIcon: isSelected,
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selectedFilters);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: AppTextStyles.buttonLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
