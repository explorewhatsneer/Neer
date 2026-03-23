import 'package:flutter/material.dart';
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';
import '../main.dart';
import '../services/supabase_service.dart';
import '../widgets/common/glass_panel.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/friend/friend_profile_widgets.dart' show FriendEmptyCard;

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final SupabaseService _service = SupabaseService();
  final String _uid = supabase.auth.currentUser!.id;
  late Stream<List<Map<String, dynamic>>> _notesStream;

  @override
  void initState() {
    super.initState();
    _notesStream = _service.getUserNotes(_uid);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(AppStrings.myNotesTitle, style: NeerTypography.h3.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _notesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ShimmerList(itemCount: 5);
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: FriendEmptyCard(
                      icon: Icons.notes_rounded,
                      title: AppStrings.notebookEmpty,
                      subtitle: AppStrings.notebookEmptyDesc,
                    ),
                  );
                }
                final notes = snapshot.data!;
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final note = notes[i];
                    final placeName = (note['places'] as Map?)?['name'] as String? ??
                        note['place_name'] as String? ?? '';
                    final content = note['content'] as String? ?? note['note'] as String? ?? '';
                    return GestureDetector(
                      onTap: () => _showNoteDetail(context, note),
                      child: GlassPanel.card(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (placeName.isNotEmpty) ...[
                                  const Icon(Icons.location_on_rounded, size: 12, color: Colors.white54),
                                  const SizedBox(width: 4),
                                  Text(placeName, style: NeerTypography.caption.copyWith(
                                    color: Colors.white.withValues(alpha: 0.55), fontSize: 11,
                                  )),
                                ],
                                const Spacer(),
                                Text(note['created_at'] != null
                                    ? _formatDate(note['created_at'].toString()) : '',
                                  style: NeerTypography.caption.copyWith(
                                    color: Colors.white.withValues(alpha: 0.35), fontSize: 10,
                                  )),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(content,
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: NeerTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNoteDetail(BuildContext context, Map<String, dynamic> note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => GlassPanel.sheet(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Builder(builder: (ctx) {
              final pn = (note['places'] as Map?)?['name'] as String? ??
                  note['place_name'] as String? ?? '';
              if (pn.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  const Icon(Icons.location_on_rounded, size: 14, color: Colors.white54),
                  const SizedBox(width: 4),
                  Text(pn, style: NeerTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.6))),
                ]),
              );
            }),
            Text(note['content'] as String? ?? note['note'] as String? ?? '',
              style: NeerTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.9), height: 1.5)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day}.${d.month.toString().padLeft(2,'0')}.${d.year}';
    } catch (_) { return ''; }
  }
}
