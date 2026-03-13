import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _ScreenState(),
      child: const _LoginScreenBody(),
    );
  }
}

class _LoginScreenBody extends StatelessWidget {
  const _LoginScreenBody();

  @override
  Widget build(BuildContext context) {
    final screenState = _ScreenState.s(context, true);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 35),
              Text("Login", style: TextStyle(fontSize: 32)),
              SizedBox(height: 80),
              TextFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  filled: true,
                  hintText: "Enter your email",

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(
                      width: 0,
                      color: Colors.transparent,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(width: 1),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(
                      color: Colors.red.withAlpha(200),
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(
                      color: Colors.red.withAlpha(200),
                      width: 1,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(width: 2),
                  ),
                ),
              ),

              SizedBox(height: 20),
              TextFormField(
                obscureText: screenState.isPasswordHidden,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.password),
                  suffixIcon: GestureDetector(
                    onTap: () => screenState.togglePwdVsibility(),
                    child: Icon(
                      screenState.isPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),

                  filled: true,
                  hintText: "Enter Password",

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(
                      width: 0,
                      color: Colors.transparent,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(width: 1),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(
                      color: Colors.red.withAlpha(200),
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(
                      color: Colors.red.withAlpha(200),
                      width: 1,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(width: 2),
                  ),
                ),
              ),

              SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    shadowColor: Colors.black.withAlpha(100),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {Navigator.pushNamed(context, '/home');},
                  child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 15),),
                ),
              ),
              SizedBox(height: 25),
              TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: Text("Dont have an account? Register here"))
            ],
          ),
        ),
      ),
    );
  }
}

class _ScreenState extends ChangeNotifier {
  static _ScreenState s(BuildContext context, [listen = false]) =>
      Provider.of<_ScreenState>(context, listen: listen);

  bool isPasswordHidden = true;
  void togglePwdVsibility() {
    isPasswordHidden = !isPasswordHidden;
    notifyListeners();
  }
}
