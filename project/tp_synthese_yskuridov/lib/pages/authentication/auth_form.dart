import 'package:flutter/material.dart';

class AuthFormWidget extends StatefulWidget {
  final void Function(
    String email,
    String password,
    String username,
    bool isLogin,
  ) _submitForm;
  const AuthFormWidget(this._submitForm, {Key? key}) : super(key: key);

  @override
  State<AuthFormWidget> createState() => _AuthFormWidgetState();
}

class _AuthFormWidgetState extends State<AuthFormWidget> {
  final _key = GlobalKey<FormState>();
  var _showLogin = true;
  String _email = "";
  String _username = "";
  String _password = "";

  void _submit() {
    final isValid = _key.currentState?.validate();
    FocusScope.of(context).unfocus();

    if (isValid ?? false) {
      _key.currentState?.save();

      widget._submitForm(
        _email.trim(),
        _password.trim(),
        _username.trim(),
        _showLogin,
      );
      _showLogin = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
      margin: EdgeInsets.all(20),
      child: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _key,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              key: const ValueKey("email"),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Adresse courriel"),
              validator: (val) {
                if (val!.isEmpty || val.length < 8) {
                  return 'Au moins 7 caracteres.';
                }
                return null;
              },
              onSaved: (value) {
                _email = value!;
              },
            ),
            if (!_showLogin)
              TextFormField(
                key: const ValueKey("username"),
                keyboardType: TextInputType.name,
                decoration:
                    const InputDecoration(labelText: "Nom d'utilisateur"),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Au moins 7 caracteres.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value!;
                },
              ),
            TextFormField(
              key: const ValueKey("password"),
              keyboardType: TextInputType.visiblePassword,
              decoration: const InputDecoration(labelText: "Mot de passe"),
              obscureText: true,
              validator: (val) {
                if (val!.isEmpty || val.length < 8) {
                  return 'Au moins 7 caracteres.';
                }
                return null;
              },
              onSaved: (value) {
                _password = value!;
              },
            ),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
              onPressed: (() {
                _submit();
              }),
              child: Text(_showLogin ? "Connexion" : "Créer un compte"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _showLogin = !_showLogin;
                });
              },
              child:
                  Text(_showLogin ? "Créer un compte" : "J'ai déjà un compte"),
            ),
          ]),
        ),
      )),
    ));
  }
}
