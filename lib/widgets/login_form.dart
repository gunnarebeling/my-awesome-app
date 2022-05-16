import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/login_bloc.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String errorMessage = "";
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Center(
          child: Text('Login Form'),
        ),
        if (!errorMessage.isEmpty)
          Text(
            errorMessage,
            style: TextStyle(color: Colors.red),
          ),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
          ),
        ),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
          ),
        ),
        TextButton(
          onPressed: () {
            LoginBloc()
                .login(_emailController.text, _passwordController.text)
                .catchError((error) {
              setState(() {
                errorMessage = error.error.message;
              });
            });
          },
          child: const Text('Login'),
        ),
      ],
    );
  }
}
