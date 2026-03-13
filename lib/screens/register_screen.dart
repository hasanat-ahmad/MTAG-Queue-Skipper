import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final cnicMaskFormatter = MaskTextInputFormatter(
    mask: 'xxxxx-xxxxxxx-x',
    filter: {"x": RegExp(r'[0-9]')},
  );

  final phoneMaskFormatter = MaskTextInputFormatter(
    mask: "03xx-xxxxxxx",
    filter: {"x": RegExp(r'[0-9]')},
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 35),
              Text("Register", style: TextStyle(fontSize: 32)),
              SizedBox(height: 50),
              Text("Please fill in the details below to register"),
              SizedBox(height: 25),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  filled: true,
                  hintText: "email@example.com",
          
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
                ),
              ),
              SizedBox(height: 25),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.password),
                  filled: true,
                  hintText: "Password",
          
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
                ),
              ),
              SizedBox(height: 25),
              TextFormField(
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  filled: true,
                  hintText: "Full name",
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
                ),
              ),
              SizedBox(height: 25),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [cnicMaskFormatter],
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.verified_user),
                  filled: true,
                  hintText: "CNIC",
          
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
                ),
              ),
              SizedBox(height: 25),
              TextFormField(
                keyboardType: TextInputType.phone,
                inputFormatters: [phoneMaskFormatter],
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  filled: true,
                  hintText: "Phone number",
          
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
                ),
              ),
              SizedBox(height: 25),
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
            ],
          ),
        ),
      ),
    );
  }
}

