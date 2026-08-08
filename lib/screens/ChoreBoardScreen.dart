import 'dart:async';

import 'package:flutter/material.dart';
import '../services/DashboardService.dart';
import '../theme/themedata.dart';

/// Screen 3 — The Chore Wheel & Task Board.
///
/// A dedicated screen for assigning, tracking and completing daily apartment
/// chores, with full Firestore CRUD and live sync:
///
///   * **Cloud Firestore CRUD** — add a chore, assign it to a specific
///     roommate, reassign / edit it, mark it **Done**, or delete it. Changes
///     are written to Firestore and re-stream to every device.
///   * **Complex logic & UI** — a dynamic priority badge system
///     (`Urgent` = glowing red, `Normal` = blue) and tappable category filters
///     (Kitchen, Cleaning, Groceries, …) that instantly filter and re-sort.
///   * **The Chore Wheel** — an animated fair-spin wheel that randomly pairs a
///     pending chore with a roommate.
///
/// The board is driven by real-time `StreamBuilder`s on [DashboardService] —
/// there is no manual refresh; Firestore does the syncing.
class ChoreBoardScreen extends StatefulWidget {
  const ChoreBoardScreen({super.key});

  @override
  State<ChoreBoardScreen> createState() => _ChoreBoardScreenState();
}

class _ChoreBoardScreenState extends State<ChoreBoardScreen> {
  final DashboardService _dashboard = DashboardService();

  String _categoryFilter = 'All';
  bool _busy = false;

  StreamSubscription<List<Member>>? _membersSub;
  List<Member> _members = const [];

  @override
  void initState() {
    super.initState();
    // Keep a live roommate list handy for assignment pickers + avatars.
    _membersSub = _dashboard.membersStream.listen((members) {
      if (mounted) setState(() => _members = members);
    });
  }

  @override
  void dispose() {
    _membersSub?.cancel();
    super.dispose();
  }

  void _toast(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: color ?? AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
  }