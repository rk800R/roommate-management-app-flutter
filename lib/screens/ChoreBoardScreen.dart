import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/app_service.dart';
import '../theme/themedata.dart';

class ChoreBoardScreen extends StatefulWidget {
  const ChoreBoardScreen({super.key});
  @override
  State<ChoreBoardScreen> createState() => _ChoreBoardScreenState();
}

class _ChoreBoardScreenState extends State<ChoreBoardScreen> {
  final _service = AppService();
  String? _categoryFilter;
  static const String aptId = 'default_apt';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Stack(
          children: [
            AppWidgets.glowOrb(top: -140, left: -100, size: 360, color: AppColors.violetOrb),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildFilters(),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _service.choresStream(aptId, _categoryFilter),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        final chores = snapshot.data!.docs
                          ..sort((a, b) => ((a.data() as Map)['isDone'] == true ? 1 : 0).compareTo((b.data() as Map)['isDone'] == true ? 1 : 0));
                        
                        return ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: chores.length,
                          itemBuilder: (context, i) => _ChoreTile(chore: chores[i], aptId: aptId),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Add chore logic simplified for footprint
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: AppColors.icon)),
        const Text('Chore Board', style: AppTextStyles.heading),
      ],
    ),
  );

  Widget _buildFilters() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: ['All', 'Kitchen', 'Cleaning', 'Groceries'].map((c) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(c),
          selected: _categoryFilter == c || (_categoryFilter == null && c == 'All'),
          onSelected: (s) => setState(() => _categoryFilter = c == 'All' ? null : c),
        ),
      )).toList(),
    ),
  );
}

class _ChoreTile extends StatelessWidget {
  final QueryDocumentSnapshot chore;
  final String aptId;
  const _ChoreTile({required this.chore, required this.aptId});

  @override
  Widget build(BuildContext context) {
    final data = chore.data() as Map;
    final isDone = data['isDone'] == true;
    final service = AppService();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppWidgets.glassCard(
        padding: AppPadding.tileInner,
        fillColor: AppColors.glassFillChore,
        borderColor: AppColors.glassBorder,
        boxShadow: const [],
        child: Row(
          children: [
            Checkbox(
              value: isDone,
              onChanged: (v) => service.toggleChore(aptId, chore.id, v!),
              activeColor: AppColors.success,
            ),
            Expanded(
              child: Text(data['title'] ?? 'Untitled', style: isDone ? AppTextStyles.choreTitleCompleted : AppTextStyles.choreTitle),
            ),
            if (data['priority'] == 'Urgent')
              Container(
                padding: AppPadding.badge,
                decoration: AppDecorations.urgentBadge(),
                child: const Text('Urgent', style: AppTextStyles.urgentBadge),
              ),
          ],
        ),
      ),
    );
  }
}
