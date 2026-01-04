 import 'package:flutter/material.dart';
 import 'package:ai_app/services/calendar_service.dart';
 import 'package:ai_app/models/calendar_event.dart';
 import 'package:ai_app/utils/productivity_calculator.dart';
 import 'package:ai_app/screens/PrivacyPolicy.dart';
 import 'package:ai_app/services/microsoft_auth_service.dart';
 import 'package:ai_app/screens/login.dart';
 import 'package:http/http.dart' as http;
 import 'dart:convert';
 import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';

 class DashboardScreen extends StatefulWidget {
   final String accessToken;

   DashboardScreen({required this.accessToken});

   @override
   _DashboardScreenState createState() => _DashboardScreenState();
 }

 class _DashboardScreenState extends State<DashboardScreen> {
   // Define state variables HERE
   List<CalendarEvent> events = [];
   int productivityScore = 0;
   bool isLoading = true;

   // USER NAME VARIABLE - This is what you were missing!
   String userName = 'User';  // Default value
   String userEmail = '';

   @override
   void initState() {
     super.initState();
     loadUserDataAndCalendar();
   }
   Future<void> _handleLogout(BuildContext context) async {
     final confirm = await showDialog<bool>(
       context: context,
       builder: (context) => AlertDialog(
         title: Text('Logout'),
         content: Text('Are you sure you want to logout?'),
         actions: [
           TextButton(
             onPressed: () => Navigator.of(context).pop(false),
             child: Text('Cancel'),
           ),
           TextButton(
             onPressed: () => Navigator.of(context).pop(true),
             child: Text('Logout'),
           ),
         ],
       ),
     );

     if (confirm == true) {
       final authService = MicrosoftAuthService();
       await authService.signOut();

       // Clear stored credentials
       final prefs = await SharedPreferences.getInstance();
       await prefs.remove('isLoggedIn');
       await prefs.remove('accessToken');

       if (!context.mounted) return;

       Navigator.of(context).pushAndRemoveUntil(
         MaterialPageRoute(builder: (context) => login()),
             (route) => false,
       );
     }
   }
   Future<void> loadUserDataAndCalendar() async {
     try {
       CalendarService service = CalendarService();

       // Fetch user info from Microsoft Graph
       Map<String, dynamic> userInfo =
       await service.getUserInfo(widget.accessToken);

       // Fetch calendar events
       List<CalendarEvent> fetchedEvents =
       await service.getTodaysEvents(widget.accessToken);

       // Calculate score
       int score = ProductivityCalculator.calculateScore(fetchedEvents);

       setState(() {
         // Update userName from API response
         userName = userInfo['displayName'] ?? 'User';
         userEmail = userInfo['mail'] ?? userInfo['userPrincipalName'] ?? '';

         events = fetchedEvents;
         productivityScore = score;
         isLoading = false;
       });
     } catch (e) {
       print('Error: $e');
       setState(() {
         isLoading = false;
       });
     }
   }

   @override
   Widget build(BuildContext context) {
     if (isLoading) {
       return Scaffold(
         body: Center(child: CircularProgressIndicator()),
       );
     }

     return Scaffold(
       appBar: AppBar(
         backgroundColor: Color(0xFF7C3AED),
         toolbarHeight: 120,
         title: Text('Welcome, \n$userName !',style: TextStyle(
           fontSize: 20,
           color: Colors.white,
           fontFamily: 'Poppins',
           fontWeight: FontWeight.w600
         ),),
       ),
       body: ListView(
         padding: EdgeInsets.all(16),
         children: [
           SizedBox(height: 11,),
           _buildProductivityScoreCard(),
           SizedBox(height: 20),
           _buildMeetingsCard(),
           SizedBox(height: 20,),
           buildImportantTips(productivityScore),
           SizedBox(height: 35,),
           tipsCards(),
           SizedBox(height: 30,),
           InkWell(
             onTap: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(
                   builder: (context) => PrivacyScreen(),
                 ),
               );
             },
             child: Center(child: Text("Privacy Policy",style: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.w700,fontSize: 18),)),
           ),
           SizedBox(height: 20,),
         ElevatedButton.icon(
             onPressed: () => _handleLogout(context),
             icon: Icon(Icons.logout),
             label: Text('Logout',style: TextStyle(fontFamily: 'Poppins',fontSize: 16,fontWeight: FontWeight.w700),),
             style: ElevatedButton.styleFrom(
               padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
             ),
           ),
           SizedBox(height: 40,)
         ],
       ),
     );
   }

   // Your other widget methods...
   Widget _buildProductivityScoreCard() {
     return Card(
       elevation: 12,
       child: Padding(
         padding: EdgeInsets.all(30),
         child: Column(
           children: [
             Text(
               'Productivity Score',
               style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600,fontFamily: 'Poppins',color: Colors.blueGrey),
             ),
             SizedBox(height: 10),
             Text(
               '$productivityScore',
               style: TextStyle(
                 fontSize: 64,
                 fontFamily: 'Poppins',
                 fontWeight: FontWeight.bold,
                 color: _getScoreColor(productivityScore),
               ),
             ),
             Text('/ 100', style: TextStyle(fontFamily:'Poppins',fontSize: 24, color: Colors.grey,fontWeight: FontWeight.w700)),
             SizedBox(height: 20,),
             Center(child: productivityText(productivityScore)),
           ],
         ),
       ),
     );
   }
   Widget productivityText(int score) {
     if (score >= 90 && score <= 100) {
       return Text("You're in a great flow—maintain this balance.",style: TextStyle(color: Colors.green,fontWeight: FontWeight.w700,fontFamily: 'Poppins',fontSize: 16),);
     }
     if (score >= 75 && score<= 89){
       return Text("Strong productivity—optimize your routine to reach peak performance.",style: TextStyle(color: Colors.lightBlueAccent,fontWeight: FontWeight.w700,fontFamily: 'Poppins',fontSize: 16),);
     }
     if (score >= 50 && score<= 74){
       return Text("Room for improvement—prioritize tasks and reduce distractions.",style: TextStyle(color: Color(0xFFFF9800),fontWeight: FontWeight.w700,fontFamily: 'Poppins',fontSize: 16),);
     }
     if (score >= 25 && score<= 49){
       return Text("You’re stretched thin—focus on essentials and avoid overload.",style: TextStyle(color: Color(0xFFF57C00),fontWeight: FontWeight.w700,fontFamily: 'Poppins',fontSize: 16),);
     }
     if (score >= 0 && score<= 24){
       return Text("Time to reset—rest, reorganize, and protect your energy.",style: TextStyle(color: Colors.red,fontWeight: FontWeight.w700,fontFamily: 'Poppins',fontSize: 16),);
     }
     return const SizedBox.shrink();
   }
   Widget tipsCards(){
     return Card(
       elevation: 20,
       child: Padding(
         padding: EdgeInsets.all(30),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text("💡 Hint",style: TextStyle(fontFamily: 'Poppins',fontSize: 20,fontWeight: FontWeight.w600,),),
             SizedBox(height: 20,),
             Row(
               children: [
                 Text("90-100 : ",style: TextStyle(fontWeight: FontWeight.w900,fontFamily: 'Poppins',fontSize: 18,color: Colors.green),),
                 Text(" Peak Performance",style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.w400),)
               ],
             ),
             Row(
               children: [
                 Text("75-89   : ",style: TextStyle(fontWeight: FontWeight.w900,fontFamily: 'Poppins',fontSize: 18,color: Colors.lightBlueAccent),),
                 Text(" Going Strong",style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.w400),)
               ],
             ),
             Row(
               children: [
                 Text("50-74   : ",style: TextStyle(fontWeight: FontWeight.w900,fontFamily: 'Poppins',fontSize: 18,color: Color(0xFFFF9800)),),
                 Text(" Needs Focus",style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.w400),)
               ],
             ),
             Row(
               children: [
                 Text("25-49   : ",style: TextStyle(fontWeight: FontWeight.w900,fontFamily: 'Poppins',fontSize: 18,color: Color(0xFFF57C00)),),
                 Text(" Under Pressure",style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.w400),)
               ],
             ),
             Row(
               children: [
                 Text("0-24      : ",style: TextStyle(fontWeight: FontWeight.w900,fontFamily: 'Poppins',fontSize: 18,color: Colors.red),),
                 Text(" Overloaded",style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.w400),)
               ],
             )
           ],
         ),
       ),
     );
   }
   Widget _buildMeetingsCard() {
     return Card(
       elevation: 12,
       child: Padding(
         padding: EdgeInsets.all(30),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(
               '🗓️   Today\'s Meetings',
               style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600,fontFamily: 'Poppins'),
             ),
             SizedBox(height: 15),
             if (events.isEmpty)
               Center(child: Text('No meetings today !',style: TextStyle(fontSize: 18,fontFamily: 'Poppins',color: Colors.red,fontWeight: FontWeight.w600),))
             else
               ...events.map((event) => ListTile(
                 leading: Icon(Icons.event, color: Colors.blue),
                 title: Text(event.subject),
                 subtitle: Text(
                     '${_formatTime(event.start)} - ${_formatTime(event.end)}'
                 ),
               )),
             SizedBox(height: 30,),
             Material(
               color: Colors.blue,
               borderRadius: BorderRadius.circular(20),
               elevation: 10,
               child: Padding(
                   padding: EdgeInsets.all(10),
                   child: Center(
                     child: InkWell(
                      onTap: ()async {
                        final Uri url = Uri.parse("https://outlook.live.com/calendar/0/view/workweek");

                        if(!await launchUrl(
                          url,
                          mode:
                            LaunchMode.externalApplication,
                        )){
                          throw 'Could not launch $url';
                        }
     },
                       child: Text("Add Meeting",style: TextStyle(fontSize: 17,fontFamily: 'Poppins',color: Colors.white,fontWeight: FontWeight.w600),),
                     ),
                   ),
               
               ),
               
             )
           ],
         ),
       ),
     );
   }

   Widget buildImportantTips(productivityScore){
     return Card(
       elevation: 18,
       child: Padding(
           padding: EdgeInsets.all(30),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text("💎  Important Tips !",style: TextStyle(fontFamily: 'Poppins',fontSize: 20,fontWeight: FontWeight.w600,),),
             SizedBox(height: 20,),
             importantMessage(productivityScore),
           ],
         ),
       ),
     );
   }

  Widget importantMessage(int score){
     if(score >= 90 && score <=100){
       return Text("► Maintain your current routine; consistency is your biggest strength.\n"
           "► Use free time for deep work or long-term goals.\n"
           "► Start learning advanced or high-impact skills.\n"
           "► Avoid over-optimizing—don’t burn out",style: TextStyle(fontWeight: FontWeight.w400,fontFamily: 'Poppins',fontSize: 15),);
     }
     else if(score >= 75 && score <=89){
       return Text("► Identify small distractions and eliminate them.\n"
           "► Prioritize tasks using a daily top-3 rule\n"
           "► Allocate at least 1 hour to skill improvement.\n"
           "► Improve sleep and energy management\n",style: TextStyle(fontWeight: FontWeight.w400,fontFamily: 'Poppins',fontSize: 15),);
     }
     else if(score >= 50 && score <=74){
       return Text("► Plan your day in advance to reduce wasted time\n"
           "► Break big tasks into smaller, focused sessions\n"
           "► Reduce unnecessary screen time\n"
           "► Focus on consistency rather than perfection",style: TextStyle(fontWeight: FontWeight.w400,fontFamily: 'Poppins',fontSize: 15),);
     }
     else if(score >= 25 && score <=49){
       return Text("► Focus only on high-priority tasks\n"
           "► Avoid multitasking; do one thing at a time\n"
           "► Optimize routines (batch similar tasks).\n"
           "► Cut non-essential activities\n",style: TextStyle(fontWeight: FontWeight.w400,fontFamily: 'Poppins',fontSize: 15),);
     }
     else if(score >= 0 && score <=24){
       return Text("► Pause and reassess your workload immediately\n"
           "► Delegate or postpone non-critical tasks\n"
           "► Fix sleep, health, and stress first\n"
           "► Start with small wins to regain control\n",style: TextStyle(fontWeight: FontWeight.w400,fontFamily: 'Poppins',fontSize: 15),);
     }
     else{
       return Text("hfb");
     }
  }

   Color _getScoreColor(int score) {
     if (score >= 75) return Colors.green;
     if (score >= 50) return Colors.orange;
     return Colors.red;
   }

   String _formatTime(DateTime time) {
     return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
   }
 }