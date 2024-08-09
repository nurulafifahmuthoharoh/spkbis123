import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabaseClient = Supabase.instance.client;

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email and password cannot be empty')),
      );
      return;
    }

    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        if (email == 'admin@gmail.com') {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid email or password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(33, 137, 156, 0.15),
                Colors.white,
                Colors.white,
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Expanded(flex: 1, child: Center()),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/logo2.svg',
                        height: size.height / 8,
                        width: size.height / 8,
                      ),
                      const SizedBox(height: 16),
                      Text.rich(
                        TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 24.0,
                            color: const Color(0xFF21899C),
                            letterSpacing: 2.0,
                          ),
                          children: const [
                            TextSpan(
                              text: 'SMART',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: 'BUSEVAL',
                              style: TextStyle(
                                color: Color(0xFFFE9879),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'login untuk melihat hasil evaluasi kelayakan bis',
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          color: const Color(0xFF969AA8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Email',
                            style: GoogleFonts.inter(
                              fontSize: 14.0,
                              color: Colors.black,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            style: GoogleFonts.inter(
                              fontSize: 18.0,
                              color: const Color(0xFF151624),
                            ),
                            maxLines: 1,
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: const Color(0xFF151624),
                            decoration: InputDecoration(
                              hintText: 'Masukan Email',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14.0,
                                color: const Color(0xFFABB3BB),
                                height: 1.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Password',
                            style: GoogleFonts.inter(
                              fontSize: 14.0,
                              color: Colors.black,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: GoogleFonts.inter(
                              fontSize: 18.0,
                              color: const Color(0xFF151624),
                            ),
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            cursorColor: const Color(0xFF151624),
                            decoration: InputDecoration(
                              hintText: 'Masukan password',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14.0,
                                color: const Color(0xFFABB3BB),
                                height: 1.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 24.0,
                            height: 24.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                width: 0.7,
                                color: const Color(0xFFD0D0D0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Keep me signed in',
                            style: GoogleFonts.inter(
                              fontSize: 12.0,
                              color: const Color(0xFFABB3BB),
                              height: 1.17,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Lupa password?',
                              style: GoogleFonts.inter(
                                fontSize: 12.0,
                                color: const Color(0xFFF56B3F),
                                height: 1.17,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: _signIn,
                    child: Container(
                      alignment: Alignment.center,
                      height: size.height / 13,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: const Color(0xFF21899C),
                      ),
                      child: Text(
                        'Login',
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 12.0,
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'belum punya akun? ',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: 'daftar',
                            style: TextStyle(
                              color: Color(0xFFFF7248),
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, '/register');
                              },
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
