import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule_slot_model.dart';
import '../core/utils/api_response.dart';
import '../core/repositories/base_repository.dart';

class AvailabilityProvider extends ChangeNotifier {
  final SupabaseClient _supabase;
  final _repository = ScheduleSlotsRepository(Supabase.instance.client);
  bool _isLoading = false;
  String? _error;
  List<ScheduleSlot> _slots = [];

  AvailabilityProvider(this._supabase);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ScheduleSlot> get slots => _slots;

  Future<void> fetchAvailability(String professionalId, DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.list(
        filters: {
          'professional_id': professionalId,
          'date': date.toIso8601String().split('T')[0],
        },
        orderBy: 'start_time',
      );

      if (response.hasError) {
        _error = response.error;
      } else {
        _slots = response.data ?? [];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createSlot(ScheduleSlot slot) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.create(slot);
      if (response.hasError) {
        _error = response.error;
      } else if (response.data != null) {
        _slots = [..._slots, response.data!];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSlot(String slotId, ScheduleSlot slot) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.update(slotId, slot);
      if (response.hasError) {
        _error = response.error;
      } else if (response.data != null) {
        _slots =
            _slots.map((s) => s.id == slotId ? response.data! : s).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSlot(String slotId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.delete(slotId);
      if (response.hasError) {
        _error = response.error;
      } else {
        _slots = _slots.where((slot) => slot.id != slotId).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class ScheduleSlotsRepository extends BaseRepository<ScheduleSlot> {
  ScheduleSlotsRepository(SupabaseClient supabase)
      : super(supabase, 'schedule_slots');

  @override
  ScheduleSlot fromJson(Map<String, dynamic> json) =>
      ScheduleSlot.fromJson(json);

  @override
  Map<String, dynamic> toJson(ScheduleSlot entity) => entity.toJson();
}
