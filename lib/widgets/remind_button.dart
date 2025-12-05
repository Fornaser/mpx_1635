import 'package:flutter/material.dart';
import 'package:mpx_1635/models/media_model.dart';
import 'remind_dialog.dart';
import 'package:uuid/uuid.dart';
import 'package:mpx_1635/app_details/change_notifiers/remind.dart';

class RemindButton extends StatefulWidget {
  final Book book;
  final RemindNotifier? notifier;

  const RemindButton({super.key, required this.book, this.notifier});

  @override
  State<RemindButton> createState() => _RemindButtonState();
}

class _RemindButtonState extends State<RemindButton> with SingleTickerProviderStateMixin {
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
