import 'dart:math';
import 'dart:ui';

import 'package:timer/common_libs.dart';

class PageReveal extends StatelessWidget {
  final double revealPercent;
  final Widget child;

  const PageReveal({
    super.key,
    required this.revealPercent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      clipper: CircularRevealClipper(revealPercent: revealPercent),
      child: child,
    );
  }
}

class AnimatedPageDragger {
  final bubbleWidth = 15.0;
  final fullTransitionPx = 300.0;
  final percentPerMillisecond = 0.00325;

  final TransitionGoal transitionGoal;
  final SlideUpdate slideUpdate;

  AnimationController? completionAnimationController;

  AnimatedPageDragger({
    required this.transitionGoal,
    required this.slideUpdate,
    required double slidePercent,
    required StreamController<SlideUpdate> slideUpdateStream,
    required TickerProvider vsync,
  }) {
    final startSlidePercent = slidePercent;
    double endSlidePercent;
    Duration duration;

    if (transitionGoal == TransitionGoal.open) {
      endSlidePercent = 1.0;
      final slideRemaining = 1.0 - slidePercent;

      duration = Duration(
        milliseconds: (slideRemaining / percentPerMillisecond).round(),
      );
    } else {
      endSlidePercent = 0.0;

      duration = Duration(
        milliseconds: (slidePercent / percentPerMillisecond).round(),
      );
    }

    completionAnimationController =
        AnimationController(duration: duration, vsync: vsync)
          ..addListener(() {
            final slidePercent = lerpDouble(
              startSlidePercent,
              endSlidePercent,
              completionAnimationController!.value,
            );

            slideUpdateStream.add(
              SlideUpdate(
                slidePercent!,
                UpdateType.animating,
                slideUpdate.nextPage,
              ),
            );
          })
          ..addStatusListener((AnimationStatus status) {
            //When animation has done executing
            if (status == AnimationStatus.completed) {
              //Adding to slide update stream
              slideUpdateStream.add(
                SlideUpdate(
                  slidePercent,
                  UpdateType.doneAnimating,
                  slideUpdate.nextPage,
                ),
              );
            }
          });
  }

  void run() {
    completionAnimationController?.forward(from: 0.0);
  }

  void dispose() {
    completionAnimationController?.dispose();
  }
}

enum UpdateType { dragging, doneDragging, animating, doneAnimating }

enum TransitionGoal { open, close }

// model for slide update

class SlideUpdate {
  final UpdateType updateType;
  final int nextPage;
  final double slidePercent;

  SlideUpdate(this.slidePercent, this.updateType, this.nextPage);
}

/// Custom clipper for circular page reveal.

class CircularRevealClipper extends CustomClipper<Rect> {
  final double revealPercent;

  CircularRevealClipper({required this.revealPercent});

  @override
  Rect getClip(Size size) {
    // center of rectangle
    final center = Offset(size.width / 2, size.height * 0.9);

    // Calculate distance from center to the top left corner to make sure we fill the screen via simple trigonometry.
    double theta = atan(center.dy / center.dx);
    final distanceToCorner = center.dy / sin(theta);

    final radius = distanceToCorner * revealPercent;
    final diameter = 2 * radius;

    return Rect.fromLTWH(
      center.dx - radius,
      center.dy - radius,
      diameter,
      diameter,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class PageTransition extends StatefulWidget {
  final List<Widget> pages;

  const PageTransition({super.key, required this.pages});

  @override
  State<PageTransition> createState() => _PageTransitionState();
}

class _PageTransitionState extends State<PageTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentPageIndex = 0;
  int _nextPageIndex = 1;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentPageIndex = _nextPageIndex;
          _isAnimating = false;
          _animationController.reset();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      _nextPageIndex = (_currentPageIndex + 1) % widget.pages.length;
    });

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Current page (visible when not animating)
        if (!_isAnimating) widget.pages[_currentPageIndex],

        // During animation, we show the next page with PageReveal
        if (_isAnimating)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Current page in the background
                  widget.pages[_currentPageIndex],

                  // Revealing next page
                  PageReveal(
                    revealPercent: _animation.value,
                    child: widget.pages[_nextPageIndex],
                  ),
                ],
              );
            },
          ),

        // Next button
        Positioned(
          bottom: 20,
          right: 20,
          child: ElevatedButton(
            onPressed: _goToNextPage,
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }
}
