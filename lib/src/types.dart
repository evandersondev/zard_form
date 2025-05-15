import 'package:zard/zard.dart';

typedef Resolver<T> = Future<ZardResult<T>> Function(
    Map<String, dynamic> values);
typedef SubmitHandler<T> = void Function(T data);

zardResolver<T>(ZMap schema) => (Map<String, dynamic> values) async {
      final result = await schema.safeParseAsync(values);

      return ZardResult<T>(
        success: result.success,
        data: result.data,
        error: result.error,
      );
    };
