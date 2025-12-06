import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mpx_1635/models/media_model.dart';
import 'remind_dialog.dart';
import 'package:uuid/uuid.dart';
import 'package:mpx_1635/app_details/change_notifiers/remind.dart';
import 'remind_bell_overlay.dart';
import 'package:mpx_1635/pages/media_page.dart';

class RemindButton extends StatefulWidget {
  final Book book;
  final RemindNotifier? notifier;

  const RemindButton({super.key, required this.book, this.notifier});

  @override
  State<RemindButton> createState() => _RemindButtonState();
}

class _RemindButtonState extends State<RemindButton> with SingleTickerProviderStateMixin {
  final List<Timer> _timers = [];
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 0.96).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
    ]).animate(_animController);

    _glowAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_animController);
  }

  @override
  void dispose() {
    for (final t in _timers) {
      if (t.isActive) t.cancel();
    }
    _timers.clear();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (_animController.isAnimating) return;
    await _animController.forward(from: 0.0);

    // Show dialog and get selection
    final result = await showDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const RemindDialog(),
    );

    if (result != null) {
      // Add to notifier if provided (simple in-memory add)
      if (widget.notifier != null) {
        final id = const Uuid().v4();
        widget.notifier!.addReminder(Reminder(id: id, bookId: widget.book.id, frequency: result));
      }

      // Schedule a timer for the chosen duration and show a SnackBar when it fires
      final duration = _durationFromSelection(result);
      final timer = Timer(duration, () {
        if (!mounted) return;
        // Show overlay bell animation with the book title; tapping navigates to the MediaPage
        showBellOverlay(
          context,
          title: widget.book.title,
          pageBuilder: (ctx) => MediaPage(book: widget.book),
        );
      });
      _timers.add(timer);
    }
  }

  Duration _durationFromSelection(String s) {
    switch (s) {
      case 'In 10 seconds':
        return const Duration(seconds: 10);
      case 'In one minute':
        return const Duration(minutes: 1);
      case 'Once a day':
        return const Duration(days: 1);
      case 'Once a week':
        return const Duration(days: 7);
      case 'Once a month':
        return const Duration(days: 30);
      default:
        return const Duration(seconds: 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outline glow
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: double.infinity,
                    height: 48 + (_glowAnim.value * 22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.45 * _glowAnim.value),
                          blurRadius: 18 * _glowAnim.value + 2,
                          spreadRadius: 4 * _glowAnim.value,
                        ),
                      ],
                    ),
                  ),
                ),
                Transform.scale(
                  scale: _scaleAnim.value,
                  child: ElevatedButton(
                    onPressed: _onTap,
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    child: const Text('Remind Me'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
