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
  bool _isSubmitting = false;
  final _validationCacheTimeout = Duration(milliseconds: 500);

  T? _lastValidData;
  DateTime? _lastValidationTime;
  bool _mounted = true;
  bool get isSubmitting => _isSubmitting;

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
    if (_isSubmitting) return;

    _isSubmitting = true;
    notifyListenersIfMounted();

    try {
      if (_lastValidData != null &&
          _lastValidationTime != null &&
          DateTime.now().difference(_lastValidationTime!) <
              _validationCacheTimeout) {
        await onValid(_lastValidData as T);
        return;
      }

      final result = await resolver(_values);
      _errors.clear();

      if (result.success && result.data != null) {
        _lastValidData = result.data as T;
        _lastValidationTime = DateTime.now();
        onValid(_lastValidData as T);
      } else {
        final errors = result.error?.issues ?? [];
        for (var error in errors) {
          _errors.addAll({'${error.path}': error.message});
        }
      }
    } on ZardError catch (e) {
      for (var error in e.issues) {
        _errors.addAll({'${error.path}': error.message});
      }
    } catch (e) {
      _errors.addAll({'form': 'An error ccurred: $e'});
    } finally {
      _isSubmitting = false;
      notifyListenersIfMounted();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    for (var c in controllers.values) {
      c.dispose();
    }
    _errors.clear();
    _values.clear();
    controllers.clear();
    super.dispose();
  }

  void notifyListenersIfMounted() {
    if (_mounted) {
      notifyListeners();
    }
  }
}

// class ZardResult<T> {
//   final bool success;
//   final T? data;
//   final List<ZardError>? errors;

//   ZardResult({required this.success, this.data, this.errors});
// }
