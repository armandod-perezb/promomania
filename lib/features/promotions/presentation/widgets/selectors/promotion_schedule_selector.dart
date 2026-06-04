import 'package:flutter/material.dart';

/// Modelo auxiliar de datos usado por componentes de promociones.
class PromotionScheduleData {
  final List<String> days;
  final String startTime;
  final String endTime;

  const PromotionScheduleData({
    required this.days,
    required this.startTime,
    required this.endTime,
  });
}

/// Utilidades de promociones; concentran reglas de formato, calculo o conversion reutilizables.
class PromotionScheduleUtils {
  static const dayOrder = [
    'lunes',
    'martes',
    'miercoles',
    'jueves',
    'viernes',
    'sabado',
    'domingo',
  ];

  static const shortLabels = {
    'lunes': 'Lun',
    'martes': 'Mar',
    'miercoles': 'Mie',
    'jueves': 'Jue',
    'viernes': 'Vie',
    'sabado': 'Sab',
    'domingo': 'Dom',
  };

  static PromotionScheduleData parse(String schedule) {
    final normalized = schedule.toLowerCase();
    return PromotionScheduleData(
      days: _parseDays(normalized),
      startTime: _parseTimes(normalized)[0],
      endTime: _parseTimes(normalized)[1],
    );
  }

  static String formatSchedule(List<String> days, String start, String end) {
    return '${formatDays(days)} ${_formatCompactTime(start)}-${_formatCompactTime(end)}';
  }

  static String formatDays(List<String> days) {
    if (days.isEmpty) return 'Lun-Vie';

    final indexes =
        days.map(dayOrder.indexOf).where((index) => index != -1).toList()
          ..sort();

    if (indexes.isEmpty) return 'Lun-Vie';

    final isConsecutive = indexes.length == indexes.last - indexes.first + 1;
    if (isConsecutive && indexes.length > 1) {
      return '${shortLabels[dayOrder[indexes.first]]}-${shortLabels[dayOrder[indexes.last]]}';
    }

    return indexes.map((index) => shortLabels[dayOrder[index]]).join(', ');
  }

  static String _formatCompactTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.first) ?? 9;
    final suffix = hour >= 12 ? 'pm' : 'am';
    final twelveHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$twelveHour$suffix';
  }

  static List<String> _parseDays(String normalized) {
    const aliases = <String, String>{
      'lun': 'lunes',
      'lunes': 'lunes',
      'mar': 'martes',
      'martes': 'martes',
      'mie': 'miercoles',
      'mié': 'miercoles',
      'mier': 'miercoles',
      'miércoles': 'miercoles',
      'miercoles': 'miercoles',
      'jue': 'jueves',
      'jueves': 'jueves',
      'vie': 'viernes',
      'viernes': 'viernes',
      'sab': 'sabado',
      'sáb': 'sabado',
      'sabado': 'sabado',
      'sábado': 'sabado',
      'dom': 'domingo',
      'domingo': 'domingo',
    };

    final range = RegExp(r'([a-záéíóú]{3,10})\s*-\s*([a-záéíóú]{3,10})');
    final match = range.firstMatch(normalized);
    if (match != null) {
      final startDay = aliases[match.group(1) ?? ''];
      final endDay = aliases[match.group(2) ?? ''];
      if (startDay != null && endDay != null) {
        final startIndex = dayOrder.indexOf(startDay);
        final endIndex = dayOrder.indexOf(endDay);
        if (startIndex != -1 && endIndex != -1 && startIndex <= endIndex) {
          return dayOrder.sublist(startIndex, endIndex + 1);
        }
      }
    }

    final explicitDays = <String>[];
    for (final entry in aliases.entries) {
      if (normalized.contains(entry.key) &&
          !explicitDays.contains(entry.value)) {
        explicitDays.add(entry.value);
      }
    }

    if (explicitDays.isNotEmpty) return explicitDays;
    return dayOrder.sublist(0, 5);
  }

  static List<String> _parseTimes(String normalized) {
    final timeRange = RegExp(
      r'(\d{1,2})(?::\d{2})?\s*(am|pm)?\s*-\s*(\d{1,2})(?::\d{2})?\s*(am|pm)?',
    );
    final match = timeRange.firstMatch(normalized);
    if (match == null) return ['09:00', '19:00'];

    return [
      _normalizeHourTo24h(match.group(1) ?? '9', match.group(2)),
      _normalizeHourTo24h(match.group(3) ?? '19', match.group(4)),
    ];
  }

  static String _normalizeHourTo24h(String rawHour, String? period) {
    var hour = int.tryParse(rawHour) ?? 9;
    final suffix = period?.toLowerCase().trim() ?? '';

    if (suffix == 'pm' && hour < 12) hour += 12;
    if (suffix == 'am' && hour == 12) hour = 0;
    if (hour < 0) hour = 0;
    if (hour > 23) hour = 23;

    return '${hour.toString().padLeft(2, '0')}:00';
  }
}

/// Widget selector de promociones; encapsula seleccion, validacion visual y callbacks de formulario.
class PromotionScheduleSelector extends StatefulWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const PromotionScheduleSelector({
    super.key,
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  State<PromotionScheduleSelector> createState() =>
      _PromotionScheduleSelectorState();
}

/// Estado interno de `PromotionScheduleSelector`; coordina datos, eventos y reconstrucciones de la pantalla.
class _PromotionScheduleSelectorState extends State<PromotionScheduleSelector> {
  static const _primaryColor = Color(0xFFFF5733);
  static const _textDark = Color(0xFF1A1A2E);
  static const _textGray = Color(0xFF8A8A9A);
  static const _timeOptions = [
    '06:00',
    '07:00',
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
    '23:00',
  ];

  late Set<String> _selectedDays;
  late String _startTime;
  late String _endTime;

  @override
  void initState() {
    super.initState();
    final initial = PromotionScheduleUtils.parse(widget.controller.text);
    _selectedDays = initial.days.toSet();
    _startTime = _safeTime(initial.startTime, fallback: '09:00');
    _endTime = _safeTime(initial.endTime, fallback: '19:00');
    _syncController(notify: false);
  }

  String _safeTime(String value, {required String fallback}) {
    return _timeOptions.contains(value) ? value : fallback;
  }

  void _syncController({bool notify = true}) {
    final schedule = PromotionScheduleUtils.formatSchedule(
      _orderedSelectedDays,
      _startTime,
      _endTime,
    );
    widget.controller.text = schedule;
    if (notify) widget.onChanged?.call(schedule);
  }

  List<String> get _orderedSelectedDays {
    final days = PromotionScheduleUtils.dayOrder
        .where(_selectedDays.contains)
        .toList();
    return days.isEmpty ? PromotionScheduleUtils.dayOrder.sublist(0, 5) : days;
  }

  void _setPreset(List<String> days, String start, String end) {
    setState(() {
      _selectedDays = days.toSet();
      _startTime = start;
      _endTime = end;
      _syncController();
    });
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day) && _selectedDays.length > 1) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
      _syncController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.errorText != null
              ? Colors.red.withValues(alpha: 0.35)
              : const Color(0xFFE8EAF0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: _primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Horario de la promoción',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                  ),
                ),
              ),
              _buildSummaryPill(),
            ],
          ),
          const SizedBox(height: 12),
          _buildPresets(),
          const SizedBox(height: 14),
          _buildDayPicker(),
          const SizedBox(height: 14),
          _buildTimePickers(),
          if (widget.errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.controller.text,
        style: const TextStyle(
          color: _primaryColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildPresets() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildPresetChip(
          label: 'Entre semana',
          icon: Icons.work_outline_rounded,
          onTap: () => _setPreset(
            PromotionScheduleUtils.dayOrder.sublist(0, 5),
            '09:00',
            '19:00',
          ),
        ),
        _buildPresetChip(
          label: 'Fin de semana',
          icon: Icons.weekend_outlined,
          onTap: () => _setPreset(
            PromotionScheduleUtils.dayOrder.sublist(5, 7),
            '10:00',
            '18:00',
          ),
        ),
        _buildPresetChip(
          label: 'Todos los dias',
          icon: Icons.calendar_month_outlined,
          onTap: () =>
              _setPreset(PromotionScheduleUtils.dayOrder, '09:00', '21:00'),
        ),
      ],
    );
  }

  Widget _buildPresetChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 16, color: _primaryColor),
      label: Text(label),
      labelStyle: const TextStyle(
        color: _textDark,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFE8EAF0)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildDayPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dias en los que aplica',
          style: TextStyle(
            color: _textGray,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: PromotionScheduleUtils.dayOrder.map((day) {
            final selected = _selectedDays.contains(day);
            return FilterChip(
              selected: selected,
              onSelected: (_) => _toggleDay(day),
              label: Text(PromotionScheduleUtils.shortLabels[day]!),
              labelStyle: TextStyle(
                color: selected ? Colors.white : _textDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              selectedColor: _primaryColor,
              checkmarkColor: Colors.white,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected ? _primaryColor : const Color(0xFFE8EAF0),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimePickers() {
    return Row(
      children: [
        Expanded(
          child: _buildTimeDropdown(
            label: 'Inicio',
            value: _startTime,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _startTime = value;
                if (_timeOptions.indexOf(_endTime) <=
                    _timeOptions.indexOf(value)) {
                  final nextIndex = (_timeOptions.indexOf(value) + 1).clamp(
                    0,
                    _timeOptions.length - 1,
                  );
                  _endTime = _timeOptions[nextIndex];
                }
                _syncController();
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTimeDropdown(
            label: 'Fin',
            value: _endTime,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _endTime = value;
                if (_timeOptions.indexOf(_startTime) >=
                    _timeOptions.indexOf(value)) {
                  final prevIndex = (_timeOptions.indexOf(value) - 1).clamp(
                    0,
                    _timeOptions.length - 1,
                  );
                  _startTime = _timeOptions[prevIndex];
                }
                _syncController();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textGray,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          key: ValueKey(value),
          initialValue: value,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _primaryColor, width: 1.5),
            ),
          ),
          items: _timeOptions
              .map(
                (time) => DropdownMenuItem(
                  value: time,
                  child: Text(_formatReadableTime(time)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  String _formatReadableTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.first) ?? 9;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final twelveHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$twelveHour:00 $suffix';
  }
}
