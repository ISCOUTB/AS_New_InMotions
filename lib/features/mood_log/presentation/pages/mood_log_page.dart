import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../data/mock/mock_data.dart';

class MoodLogPage extends StatefulWidget {
  const MoodLogPage({super.key});

  @override
  State<MoodLogPage> createState() => _MoodLogPageState();
}

class _MoodLogPageState extends State<MoodLogPage> {
  int? _selectedMood;
  double _intensity = 3;
  final Set<String> _selectedActivities = {};
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _toggleActivity(String activity) {
    setState(() {
      if (_selectedActivities.contains(activity)) {
        _selectedActivities.remove(activity);
      } else {
        _selectedActivities.add(activity);
      }
    });
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro emocional guardado visualmente')),
    );
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(onBack: () => Navigator.pop(context))),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
              child: _MoodSelector(
                selectedMood: _selectedMood,
                onSelected: (id) => setState(() => _selectedMood = id),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: _IntensitySelector(
                value: _intensity,
                onChanged: (value) => setState(() => _intensity = value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: _ActivitiesSelector(
                selectedActivities: _selectedActivities,
                onToggle: _toggleActivity,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: _NotesCard(controller: _notesController),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 34),
              child: PrimaryButton(
                text: 'Guardar Registro',
                enabled: _selectedMood != null,
                gradientColors: const [AppColors.pink, AppColors.rose],
                onPressed: _save,
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
        bottom: 26,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.pink, AppColors.rose]),
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
                SizedBox(height: 6),
                Text(
                  'Registro Emocional',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 7),
                Text(
                  'Registra cómo te sientes hoy y qué actividades realizaste',
                  style: TextStyle(color: Color(0xFFFCE7F3), fontSize: 14, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodSelector extends StatelessWidget {
  const _MoodSelector({required this.selectedMood, required this.onSelected});

  final int? selectedMood;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Cómo te sientes?',
            style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Row(
            children: MockData.emotions.map((emotion) {
              final bool isSelected = emotion.id == selectedMood;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onSelected(emotion.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? emotion.color : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(emotion.icon, color: isSelected ? Colors.white : AppColors.textDark, size: 28),
                          const SizedBox(height: 7),
                          Text(
                            emotion.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textDark,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _IntensitySelector extends StatelessWidget {
  const _IntensitySelector({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Nivel emocional',
                  style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.pink.withOpacity(.12), shape: BoxShape.circle),
                child: Text(
                  value.round().toString(),
                  style: const TextStyle(color: AppColors.pink, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Slider(
            value: value,
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: AppColors.pink,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bajo', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              Text('Alto', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivitiesSelector extends StatelessWidget {
  const _ActivitiesSelector({required this.selectedActivities, required this.onToggle});

  final Set<String> selectedActivities;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Qué hiciste hoy?',
            style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: MockData.activities.map((activity) {
              final bool selected = selectedActivities.contains(activity);
              return ChoiceChip(
                selected: selected,
                showCheckmark: false,
                label: Text(activity),
                selectedColor: AppColors.pink,
                backgroundColor: const Color(0xFFF3F4F6),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                onSelected: (_) => onToggle(activity),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notas personales',
            style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Escribe aquí cualquier pensamiento o reflexión...',
              prefixIcon: null,
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}
