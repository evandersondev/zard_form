import 'package:flutter/material.dart';

import '../zard_form.dart';

ZForm<T> useForm<T>({
  required Resolver<T> resolver,
  Map<String, dynamic>? defaultValues,
}) {
  return ZForm<T>(
    resolver: resolver,
    defaultValues: defaultValues,
  );
}

class ZForm<T> extends ChangeNotifier {
  final Resolver<T> resolver;
  final Map<String, TextEditingController> controllers = {};
  final Map<String, String?> _errors = {};
  final Map<String, dynamic> _values = {};

  ZForm({
    required this.resolver,
    Map<String, dynamic>? defaultValues,
  }) {
    defaultValues?.forEach((key, value) {
      _values[key] = value;
    });
    for (var key in defaultValues?.keys ?? []) {
      final controller =
          TextEditingController(text: defaultValues![key]?.toString() ?? '');
      controller.addListener(() {
        _values['$key'] = controller.text;
      });
      controllers['$key'] = controller;
    }
  }

  TextEditingController register(String name) {
    controllers.putIfAbsent(name, () {
      final controller = TextEditingController();
      controller.addListener(() {
        _values[name] = controller.text;
      });
      return controller;
    });
    return controllers[name]!;
  }

  String? error(String name) => _errors[name];

  dynamic getValue(String name) => _values[name];
  void setValue(String name, dynamic value) {
    controllers[name]?.text = value.toString();
    _values[name] = value;
  }

  Map<String, dynamic> get values => _values;

  void reset([Map<String, dynamic>? initialValues]) {
    initialValues?.forEach((key, value) {
      setValue(key, value);
    });
    if (initialValues == null) {
      for (var key in controllers.keys) {
        controllers[key]?.clear();
      }
    }
  }

  Future<void> handleSubmit(SubmitHandler<T> onValid) async {
    final result = await resolver(_values);
    _errors.clear();
    if (result.success && result.data != null) {
      notifyListeners();

      onValid(result.data as T);
    } else {
      final errors = result.error?.issues ?? [];

      for (var error in errors) {
        _errors.addAll({'${error.path}': error.message});
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (var c in controllers.values) {
      c.dispose();
    }
  }
}

// class ZardResult<T> {
//   final bool success;
//   final T? data;
//   final List<ZardError>? errors;

//   ZardResult({required this.success, this.data, this.errors});
// }
