import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:monitoring_kemacetan/screens/sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() =>
      _SignUpScreenState();
}

class _SignUpScreenState
    extends State<SignUpScreen> {
  final _nameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F7FB,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 30),

              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(
                    0xFF1E3A8A,
                  ),

                  child: Icon(
                    Icons.person_add_alt_1,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight:
                      FontWeight.bold,
                  color: Color(
                    0xFF0F172A,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Daftar akun monitoring kemacetan',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                controller:
                    _nameController,

                decoration:
                    InputDecoration(
                  hintText:
                      'Nama Lengkap',

                  prefixIcon:
                      const Icon(
                    Icons.person_outline,
                  ),

                  filled: true,
                  fillColor:
                      Colors.white,

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                          20,
                        ),

                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller:
                    _emailController,

                decoration:
                    InputDecoration(
                  hintText: 'Email',

                  prefixIcon:
                      const Icon(
                    Icons.email_outlined,
                  ),

                  filled: true,
                  fillColor:
                      Colors.white,

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                          20,
                        ),

                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller:
                    _passwordController,

                obscureText: true,

                decoration:
                    InputDecoration(
                  hintText:
                      'Password',

                  prefixIcon:
                      const Icon(
                    Icons.lock_outline,
                  ),

                  filled: true,
                  fillColor:
                      Colors.white,

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                          20,
                        ),

                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller:
                    _confirmPasswordController,

                obscureText: true,

                decoration:
                    InputDecoration(
                  hintText:
                      'Konfirmasi Password',

                  prefixIcon:
                      const Icon(
                    Icons.lock_outline,
                  ),

                  filled: true,
                  fillColor:
                      Colors.white,

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                          20,
                        ),

                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF1E3A8A,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                    ),
                  ),

                  onPressed: () async {
                    if (_passwordController
                            .text !=
                        _confirmPasswordController
                            .text) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password tidak sama',
                          ),
                        ),
                      );

                      return;
                    }

                    try {
                      UserCredential
                          userCredential =
                          await FirebaseAuth
                              .instance
                              .createUserWithEmailAndPassword(
                        email:
                            _emailController
                                .text,

                        password:
                            _passwordController
                                .text,
                      );

                      userCredential.user
                          ?.updateDisplayName(
                        _nameController
                            .text,
                      );

                      if (!mounted) {
                        return;
                      }

                      Navigator.pushReplacement(
                        context,

                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const SignInScreen(),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            e.toString(),
                          ),
                        ),
                      );
                    }
                  },

                  child: const Text(
                    'Daftar',

                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,

                      MaterialPageRoute(
                        builder:
                            (context) =>
                                const SignInScreen(),
                      ),
                    );
                  },

                  child: const Text(
                    'Sudah punya akun? Sign In',

                    style: TextStyle(
                      color: Color(
                        0xFF1E3A8A,
                      ),

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}