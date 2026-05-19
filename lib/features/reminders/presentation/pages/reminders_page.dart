import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_lists.dart';
import '../../../../core/models/reminder_model.dart';
import '../../../../core/utils/reminder_visuals.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../data/repositories/reminder_repository.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final ReminderRepository _repository = ReminderRepository();

  List<ReminderModel> _reminders = [];
  ReminderModel? _nextReminder;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final reminders = await _repository.getReminders();
    final nextReminder = await _repository.getNextReminder();
    if (!mounted) return;
    setState(() {
      _reminders = reminders;
      _nextReminder = nextReminder;
      _isLoading = false;
    });
  }

  Future<void> _toggleReminder(ReminderModel reminder, bool enabled) async {
    await _repository.toggleReminder(reminder.id, enabled);
    await _loadReminders();
  }

  Future<void> _deleteReminder(ReminderModel reminder) async {
    await _repository.deleteReminder(reminder.id);
    await _loadReminders();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recordatorio eliminado')),
    );
  }

  Future<void> _saveReminder(ReminderModel reminder) async {
    await _repository.saveReminder(reminder);
    await _loadReminders();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recordatorio guardado localmente')),
    );
  }

  void _openReminderEditor([ReminderModel? reminder]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return _ReminderEditorSheet(
          reminder: reminder,
          repository: _repository,
          onSave: _saveReminder,
        );
      },
    );
  }

  Future<void> _resetDefaults() async {
    await _repository.resetDefaults();
    await _loadReminders();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recordatorios restaurados')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(onBack: () => Navigator.pop(context))),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: _MainReminderCard(nextReminder: _nextReminder),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Mis recordatorios',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.textDark),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _resetDefaults,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Restaurar'),
                  ),
                ],
              ),
            ),
          ),
          SliverList.builder(
            itemCount: _reminders.length,
            itemBuilder: (context, index) {
              final reminder = _reminders[index];
              return Padding(
                padding: EdgeInsets.fromLTRB(18, index == 0 ? 10 : 6, 18, 12),
                child: _ReminderCard(
                  reminder: reminder,
                  onChanged: (value) => _toggleReminder(reminder, value),
                  onTap: () => _openReminderEditor(reminder),
                  onDelete: () => _deleteReminder(reminder),
                ),
              );
            },
          ),
          if (_reminders.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: Text('Todavía no tienes recordatorios configurados.')),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 36),
              child: PrimaryButton(
                text: 'Agregar recordatorio',
                icon: Icons.add_alert_rounded,
                gradientColors: const [AppColors.orange, AppColors.pink],
                onPressed: () => _openReminderEditor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 8,
        right: 18,
        bottom: 38,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.orange, AppColors.pink]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 2),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                Text(
                  'Recordatorios',
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 7),
                Text(
                  'Configura alertas para cuidar tu bienestar emocional.',
                  style: TextStyle(color: Color(0xFFFFEDD5), fontSize: 14, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainReminderCard extends StatelessWidget {
  const _MainReminderCard({required this.nextReminder});

  final ReminderModel? nextReminder;

  @override
  Widget build(BuildContext context) {
    final title = nextReminder?.title ?? 'Sin recordatorios activos';
    final time = nextReminder == null ? 'Activa o crea uno nuevo' : '${nextReminder!.daysLabel} · ${nextReminder!.timeLabel}';

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;
        final iconBox = Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 31),
        );
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Próximo recordatorio', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(time, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        );

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.purple, AppColors.pink]),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withOpacity(.24),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: compact
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [iconBox, const SizedBox(height: 14), content])
              : Row(children: [iconBox, const SizedBox(width: 14), Expanded(child: content)]),
        );
      },
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder, required this.onChanged, required this.onTap, required this.onDelete});

  final ReminderModel reminder;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = ReminderVisuals.colorForType(reminder.type);
    final icon = ReminderVisuals.iconForType(reminder.type);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(color: color.withOpacity(.14), borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, color: color, size: 29),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reminder.title, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                  const SizedBox(height: 3),
                  Text(reminder.subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _SmallInfo(icon: Icons.schedule_rounded, text: reminder.timeLabel),
                      _SmallInfo(icon: Icons.calendar_today_rounded, text: reminder.daysLabel),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Column(
              children: [
                Switch(
                  value: reminder.enabled,
                  activeColor: color,
                  onChanged: onChanged,
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallInfo extends StatelessWidget {
  const _SmallInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
      ],
    );
  }
}

class _ReminderEditorSheet extends StatefulWidget {
  const _ReminderEditorSheet({required this.repository, required this.onSave, this.reminder});

  final ReminderRepository repository;
  final ReminderModel? reminder;
  final ValueChanged<ReminderModel> onSave;

  @override
  State<_ReminderEditorSheet> createState() => _ReminderEditorSheetState();
}

class _ReminderEditorSheetState extends State<_ReminderEditorSheet> {
  late String _type;
  late TimeOfDay _time;
  late List<int> _days;
  late bool _enabled;

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    final reminder = widget.reminder;
    _type = reminder?.type ?? AppLists.reminderTypes.first;
    _time = TimeOfDay(hour: reminder?.hour ?? 20, minute: reminder?.minute ?? 0);
    _days = reminder?.days.toList() ?? [1, 2, 3, 4, 5, 6, 7];
    _enabled = reminder?.enabled ?? true;
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(context: context, initialTime: _time);
    if (selected == null) return;
    setState(() => _time = selected);
  }

  void _toggleDay(int day) {
    setState(() {
      if (_days.contains(day)) {
        _days.remove(day);
      } else {
        _days.add(day);
      }
      _days.sort();
    });
  }

  void _save() {
    if (_days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un día')),
      );
      return;
    }

    final now = DateTime.now();
    final reminder = widget.reminder?.copyWith(
          type: _type,
          title: _type,
          subtitle: ReminderVisuals.defaultSubtitleForType(_type),
          hour: _time.hour,
          minute: _time.minute,
          days: _days,
          enabled: _enabled,
          updatedAt: now,
        ) ??
        widget.repository.buildNewReminder(
          type: _type,
          hour: _time.hour,
          minute: _time.minute,
          days: _days,
          enabled: _enabled,
        );

    widget.onSave(reminder);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 16, 18, bottomInset + 18),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _isEditing ? 'Editar recordatorio' : 'Nuevo recordatorio',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Tipo de recordatorio'),
              items: AppLists.reminderTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type, maxLines: 1, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded, color: AppColors.primary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Hora', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    ),
                    Text(_time.format(context), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Días activos', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _DayChip(day: 1, label: 'Lun'),
                _DayChip(day: 2, label: 'Mar'),
                _DayChip(day: 3, label: 'Mié'),
                _DayChip(day: 4, label: 'Jue'),
                _DayChip(day: 5, label: 'Vie'),
                _DayChip(day: 6, label: 'Sáb'),
                _DayChip(day: 7, label: 'Dom'),
              ].map((chip) {
                final selected = _days.contains(chip.day);
                return ChoiceChip(
                  label: Text(chip.label),
                  selected: selected,
                  selectedColor: AppColors.orange,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w800),
                  side: BorderSide(color: selected ? AppColors.orange : AppColors.border),
                  showCheckmark: false,
                  onSelected: (_) => _toggleDay(chip.day),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _enabled,
              onChanged: (value) => setState(() => _enabled = value),
              contentPadding: EdgeInsets.zero,
              title: const Text('Recordatorio activo', style: TextStyle(fontWeight: FontWeight.w800)),
              activeColor: AppColors.orange,
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              text: 'Guardar recordatorio',
              icon: Icons.save_rounded,
              gradientColors: const [AppColors.orange, AppColors.pink],
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _DayChip {
  const _DayChip({required this.day, required this.label});

  final int day;
  final String label;
}
