import 'package:flutter/material.dart';

import '../zard_form.dart';

class ZFormBuilder extends StatefulWidget {
  final ZForm form;
  final Widget Function(BuildContext context, ZForm form) builder;

  const ZFormBuilder({super.key, required this.form, required this.builder});

  @override
  State<ZFormBuilder> createState() => _ZFormBuilderState();
}

class _ZFormBuilderState extends State<ZFormBuilder> {
  @override
  void initState() {
    super.initState();
    for (var controller in widget.form.controllers.values) {
      controller.addListener(_update);
    }
  }

  void _update() => setState(() {});

  @override
  void dispose() {
    for (var controller in widget.form.controllers.values) {
      controller.removeListener(_update);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.form,
      builder: (context, _) => widget.builder(context, widget.form),
    );
  }
}
