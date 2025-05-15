import 'package:flutter/cupertino.dart';
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

  void handleFormSubmit(data) async {
    await showAdaptiveDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Success'),
            content: Column(
              children: [
                Text('Email: ${data['email']}'),
                Text('Password: ${data['password']}'),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ZFormBuilder(
        form: form,
        builder: (context, form) {
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
                ElevatedButton(
                  onPressed: () async {
                    await form.handleSubmit(handleFormSubmit);
                  },
                  child: Text("Enviar"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
