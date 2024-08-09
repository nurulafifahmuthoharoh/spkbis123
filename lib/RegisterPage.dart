import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/gestures.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final SupabaseClient _supabaseClient = Supabase.instance.client;

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
                SizedBox(height: size.height / 12), // Space at the top

                logo(size.height / 8, size.height / 8),

                const SizedBox(height: 16),

                richText(24),

                const SizedBox(height: 8),

                Text(
                  'buat akun untuk melihat hasil!',
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    color: const Color(0xFF969AA8),
                  ),
                ),

                Column(
                  children: [
                    const SizedBox(height: 8),
                    buildTextField('Nama Lengkap', _fullNameController, TextInputType.name, 'Masukan nama lengkap', size),
                    const SizedBox(height: 8),
                    buildTextField('Email', _emailController, TextInputType.emailAddress, 'Masukan email', size),
                    const SizedBox(height: 8),
                    buildTextField('Password', _passwordController, TextInputType.visiblePassword, 'Masukan password', size, obscureText: true),
                    const SizedBox(height: 8),
                    buildTextField('Konfirmasi Password', _confirmPasswordController, TextInputType.visiblePassword, 'Ulangi password', size, obscureText: true),
                  ],
                ),

                const SizedBox(height: 16),

                signUpButton(size),

                const SizedBox(height: 24),

                buildFooter(size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, TextInputType keyboardType, String hintText, Size size, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.0,
            color: Colors.black,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: size.height / 13,
          child: TextField(
            controller: controller,
            style: GoogleFonts.inter(
              fontSize: 18.0,
              color: const Color(0xFF151624),
            ),
            maxLines: 1,
            keyboardType: keyboardType,
            obscureText: obscureText,
            cursorColor: const Color(0xFF151624),
            decoration: InputDecoration(
              hintText: hintText,
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
        ),
      ],
    );
  }

  Widget logo(double height_, double width_) {
    return SvgPicture.asset(
      'assets/logo2.svg',
      height: height_,
      width: width_,
    );
  }

  Widget richText(double fontSize) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: 24.0,
          color: const Color(0xFF21899C),
          letterSpacing: 2.000000061035156,
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
    );
  }

  Widget signUpButton(Size size) {
    return GestureDetector(
      onTap: _signUp,
      child: Container(
        alignment: Alignment.center,
        height: size.height / 13,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: const Color(0xFF21899C),
        ),
        child: Text(
          'Daftar',
          style: GoogleFonts.inter(
            fontSize: 14.0,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    final fullName = _fullNameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak cocok!')),
      );
      return;
    }

    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
      },
    );

    if (response.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  Widget buildFooter(Size size) {
    return Container(
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(
            fontSize: 12.0,
            color: Colors.black,
          ),
          children: <TextSpan>[
            const TextSpan(
              text: 'sudah punya akun? ',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: 'masuk',
              style: const TextStyle(
                color: Color(0xFFFF7248),
                fontWeight: FontWeight.w500,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushNamed(context, '/login');
                },
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
