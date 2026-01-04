import 'package:flutter/material.dart';
import 'screen1.dart';
import 'dashboard.dart';
import 'package:ai_app/services/microsoft_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_aad_oauth/flutter_aad_oauth.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  Map<String, dynamic>? userData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        // background-color
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4F46E5),
                Color(0xFF7C3AED),
              ]
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Image.asset(
                'assets/logos/iconHorizontal.png',
            width: 312,
            ),
            SizedBox(height: 60.0,),

            // container for button
           Material(
             elevation:20.0,
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(20.0),
             ),
             clipBehavior: Clip.antiAlias,
             child: InkWell(
               onTap: () async {
                 print("Login button tapped");
                 try {
                   final authService = MicrosoftAuthService();
                   final userData = await authService.signInWithMicrosoft();

                   print("Login completed, userData: $userData");

                   if (userData != null && userData['accessToken'] != null) {
                     final prefs = await SharedPreferences.getInstance();
                     await prefs.setBool('isLoggedIn', true);
                     await prefs.setString('accessToken', userData['accessToken']);
                     print("Navigation to dashboard");
                     if (!mounted) return;

                     Navigator.pushReplacement(
                       context,
                       MaterialPageRoute(
                         builder: (_) => DashboardScreen(
                           accessToken: userData['accessToken'],
                         )

                       ),
                     );
                   } else {
                     print("userData is null or missing accessToken");
                     if (!mounted) return;

                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                         content: Text("Login failed! userData: $userData"),
                         duration: Duration(seconds: 5),
                       ),
                     );
                   }
                 } catch (e) {
                   print("Login exception: $e");
                   if (!mounted) return;

                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                       content: Text("Login error: $e"),
                       duration: Duration(seconds: 5),
                     ),
                   );
                 }
               },
               child: Container(
                 height: 60,
                 width: 230,
                 decoration: BoxDecoration(
                   color: Colors.white,
                 ),
                 padding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 5.0),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text("Sign In with \nMicrosoft",
                     style: TextStyle(
                       fontSize: 15,
                       fontFamily: 'Poppins',
                       fontWeight: FontWeight.w700,
                       color: Colors.blue,
                     ),),
                     SizedBox(width: 20,),
                     Image.asset(
                       'assets/logos/microsoft.png',
                       width: 40,
                     )
                   ],
                 ),
               ),
             ),
           )
          ],
        ),
      ),
    );
  }
}
