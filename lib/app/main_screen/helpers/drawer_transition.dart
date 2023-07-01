import 'package:flutter/material.dart';

class DrawerTransition extends StatefulWidget {
  final Widget child;
  final AnimationController animationController;

  const DrawerTransition({
    required this.child,
    required this.animationController,
  });

  @override
  _DrawerTransitionState createState() => _DrawerTransitionState();
}

class _DrawerTransitionState extends State<DrawerTransition> {
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animation = CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(-1.0, 0.0),
        end: Offset(0.0, 0.0),
      ).animate(_animation),
      child: widget.child,
    );
  }
}
