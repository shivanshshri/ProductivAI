import 'package:flutter/material.dart';
import 'screen1.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
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
            SizedBox(height: 120.0,),

            // container for button
           Material(
             elevation:20.0,
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(30.0),
             ),
             clipBehavior: Clip.antiAlias,
             child: InkWell(
               onTap: () {
                 Navigator.pushReplacement(
                   context,
                   MaterialPageRoute(builder: (context) => AnimatedSplashScreen()),
                 );
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
                       fontSize: 16,
                       fontFamily: 'Microsoft Sans Serif',
                       fontWeight: FontWeight.w700,
                       color: Colors.black,
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
