import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true; // Toggle between Login and Signup
  var _userEmail = '';
  var _userPassword = '';
  var _isLoading = false;

  void _submitAuthForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus(); // Close keyboard

    if (!isValid) {
      return; // Don't submit if validation fails
    }

    _formKey.currentState?.save(); // Trigger onSaved for TextFormFields

    setState(() {
      _isLoading = true;
    });

    UserCredential userCredential;

    try {
      if (_isLogin) {
        // Login mode
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _userEmail.trim(),
          password: _userPassword.trim(),
        );
      } else {
        // Signup mode
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _userEmail.trim(),
          password: _userPassword.trim(),
        );
        // Optional: You could add logic here to store additional user info
        // (like a username) in Firestore after signup if needed.
      }
      // Navigation will be handled by the StreamBuilder in main.dart
      // No need to manually navigate here if using the stream approach
    } on FirebaseAuthException catch (error) {
      var message = 'An error occurred, please check your credentials!';
      if (error.message != null) {
        message = error.message!;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print(error); // For debugging general errors
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('An unexpected error occurred.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Take minimum space
                    children: <Widget>[
                      // --- Email Field ---
                      TextFormField(
                        key: const ValueKey('email'),
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        enableSuggestions: false,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration:
                            const InputDecoration(labelText: 'Email address'),
                        onSaved: (value) {
                          _userEmail = value ?? '';
                        },
                      ),
                      // --- Password Field ---
                      TextFormField(
                        key: const ValueKey('password'),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 7) {
                            return 'Password must be at least 7 characters long.';
                          }
                          return null;
                        },
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        obscureText: true, // Hide password
                        onSaved: (value) {
                          _userPassword = value ?? '';
                        },
                      ),
                      const SizedBox(height: 20),
                      // --- Submit Button ---
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        ElevatedButton(
                          onPressed: _submitAuthForm,
                          child: Text(_isLogin ? 'Login' : 'Signup'),
                        ),
                      const SizedBox(height: 10),
                      // --- Toggle Button ---
                      if (!_isLoading)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin; // Toggle the mode
                            });
                          },
                          child: Text(_isLogin
                              ? 'Create new account'
                              : 'I already have an account'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
