import 'package:flutter/material.dart';

/// Shows a temporary bell notification overlay in the top-right corner.
void showBellOverlay(BuildContext context, {bool persistUntilTap = true, Duration duration = const Duration(seconds: 3), String? title, VoidCallback? onTap, WidgetBuilder? pageBuilder}) {
  final overlay = Overlay.of(context);
  

  // Use a guard to avoid double-removal causing errors
  bool removed = false;
  final overlayState = overlay;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) {
      // Use the overlay state's context to reliably access MediaQuery
      final mq = MediaQuery.of(overlayState.context);
      final top = mq.padding.top + 12;
      final maxWidth = mq.size.width * 0.6;
      return Positioned(
        top: top,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(builder: (ctx) {
                // local handler to ensure single removal and navigate/call callback
                void handleTap() {
                  if (removed) return;
                  removed = true;
                  // remove overlay first to avoid blocking navigation
                  try {
                    entry.remove();
                  } catch (_) {}

                  // if a pageBuilder is provided, navigate using the overlay's context
                  if (pageBuilder != null) {
                    try {
                      Navigator.of(overlayState.context).push(MaterialPageRoute(builder: pageBuilder));
                    } catch (_) {}
                    return;
                  }

                  try {
                    onTap?.call();
                  } catch (_) {}
                }

                return AnimatedBell(onTap: handleTap);
              }),
              if (title != null) ...[
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: GestureDetector(
                    onTap: () {
                      if (removed) return;
                      removed = true;
                      try {
                        entry.remove();
                      } catch (_) {}

                      if (pageBuilder != null) {
                        try {
                          Navigator.of(overlayState.context).push(MaterialPageRoute(builder: pageBuilder));
                        } catch (_) {}
                        return;
                      }

                      try {
                        onTap?.call();
                      } catch (_) {}
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );

  try {
    overlay.insert(entry);
  } catch (_) {
    return;
  }

  if (!persistUntilTap) {
    Future.delayed(duration, () {
      if (removed) return;
      removed = true;
      try {
        entry.remove();
      } catch (_) {}
    });
  }
}

class AnimatedBell extends StatefulWidget {
  final VoidCallback? onTap;
  const AnimatedBell({Key? key, this.onTap}) : super(key: key);

  @override
  State<AnimatedBell> createState() => _AnimatedBellState();
}

class _AnimatedBellState extends State<AnimatedBell> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _rotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.18).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.18, end: -0.14).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: -0.14, end: 0.12).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.12, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
    ]).animate(_controller);

    _bounce = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_controller);

    // Repeat the animation continuously until the user taps the bell.
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        try {
          widget.onTap?.call();
        } catch (_) {}
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounce.value),
            child: Transform.rotate(
              angle: _rotation.value,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
                ),
                child: const Icon(Icons.notifications_active, color: Colors.green, size: 32),
              ),
            ),
          );
        },
      ),
    );
  }
}
