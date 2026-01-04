import 'package:ai_app/screens/dashboard.dart';
import 'package:flutter/material.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF7C3AED),
        toolbarHeight: 100,
        title: Text("Data & \nPrivacy Policy", style: TextStyle(fontSize: 22,
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.w600),),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SizedBox(height: 10,),
          Text("🔏 What we Access", style: TextStyle(fontWeight: FontWeight.w600,
              fontSize: 22,
              fontFamily: 'Poppins'),),
          SizedBox(height: 16,),
          bulletText("Your calendar events for today only"),
             bulletText("Meeting start and end times"),
              bulletText("Meeting titles (for context"),
              bulletText("Your basic profile information"),

          SizedBox(height: 45,),
          Text("🚫 What we DON'T Access", style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              fontFamily: 'Poppins'),),
          SizedBox(height: 16,),
          bulletText("Your emails or messages"),
          bulletText("Meeting content or recordings"),
              bulletText("Files or documents"),
              bulletText("Location or device data"),
              bulletText("Chat conversations"),

          SizedBox(height: 45,),
          Text("🎯 Why We Need This", style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              fontFamily: 'Poppins'),),
          SizedBox(height: 16,),

            bulletText("Calculate your meeting load accurately"),
            bulletText("Generate personalized productivity insights"),
            bulletText("Provide relevant improvement suggestions"),
            bulletText("Help you work smarter, not longer",),



          SizedBox(height: 45,),
          Text("🛡️ Your Data is Safe", style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              fontFamily: 'Poppins'),),
          SizedBox(height: 16,),
          bulletText("We use Microsoft's secure authentication"),
          bulletText("Data is processed, not stored permanently"),
          bulletText("No data sharing with third parties"),
          bulletText("You can revoke access anytime"),


          SizedBox(height: 40,)
        ],
      ),
    );
  }

    Widget bulletText(String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("      ✔️ ", style: TextStyle(fontSize: 16)),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

  }

