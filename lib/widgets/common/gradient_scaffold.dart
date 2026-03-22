import 'package:flutter/material.dart';
import 'premium_background.dart';

/// Scaffold wrapper with PremiumBackground mesh gradient.
///
/// Use this for standalone screens (pushed routes) that don't inherit
/// the global background from main.dart's builder.
class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;
  final bool animate;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.extendBody = false,
    this.extendBodyBehindAppBar = true,
    this.resizeToAvoidBottomInset = true,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PremiumBackground(animate: animate),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: extendBody,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          appBar: appBar,
          body: body,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
        ),
      ],
    );
  }
}
