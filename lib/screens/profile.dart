import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<AuthProvider>(context).name; // Accessing the name from Auth
    Provider.of<AuthProvider>(context).CNIC; // Accessing the CNIC from Auth
    Provider.of<AuthProvider>(
      context,
    ).phoneNumber; // Accessing the phone number from Auth
    Provider.of<AuthProvider>(context).email; // Accessing the email from Auth
    Provider.of<AuthProvider>(
      context,
    ).password; // Accessing the password from Auth
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: Card(
                  color: Colors.amber,
                  elevation: 1,
                  child: Center(
                    child: Text(
                      "${Provider.of<AuthProvider>(context).name}",
                    ),
                  ),
                ),
              ),
              Card(),
              Card(),
              Card(),
              // Text("Password: ${Provider.of<AuthProvider>(context).password}"),
            ],
          ),
        ),
      ),
    );
  }
}


// Text("Name: ${Provider.of<AuthProvider>(context).name}"),
//               Text("CNIC: ${Provider.of<AuthProvider>(context).CNIC}"),
//               Text("Phone Number: ${Provider.of<AuthProvider>(context).phoneNumber}"),
//               Text("Email: ${Provider.of<AuthProvider>(context).email}"),