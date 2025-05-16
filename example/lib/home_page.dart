import 'package:flutter/material.dart';
import 'package:zard_form/zard_form.dart';

final schema = z.map({
  'email': z.string().email(),
  'password': z.string().min(6),
});

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final form = useForm(
    resolver: zardResolver(schema),
    defaultValues: {
      'email': 'example@mail.com',
      'password': '123456',
    },
  );

  Future<void> handleFormSubmit(data) async {
    Future.delayed(Duration(seconds: 3), () async {
      print(data);
      // await showAdaptiveDialog(
      //     context: context,
      //     builder: (context) {
      //       return CupertinoAlertDialog(
      //         title: const Text('Success'),
      //         content: Column(
      //           children: [
      //             Text('Email: ${data['email']}'),
      //             Text('Password: ${data['password']}'),
      //           ],
      //         ),
      //         actions: [
      //           CupertinoDialogAction(
      //             onPressed: () => Navigator.pop(context),
      //             child: const Text('OK'),
      //           ),
      //         ],
      //       );
      //     });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ZFormBuilder(
        form: form,
        builder: (context, isSubmitting) {
          print(form.isSubmitting);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  controller: form.register('email'),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: form.error('email'),
                  ),
                ),
                TextField(
                  controller: form.register('password'),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: form.error('password'),
                  ),
                ),
                SubmitButton(
                  text: 'Enviar',
                  isLoading: isSubmitting,
                  onPressed: () => form.handleSubmit(handleFormSubmit),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;

  const SubmitButton({
    super.key,
    required this.text,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(text),
    );
  }
}
