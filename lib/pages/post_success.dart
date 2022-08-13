import 'package:flutter/services.dart';

import '../navigation.dart';
import 'package:african_springs/home/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostSuccess extends StatefulWidget {
  const PostSuccess({Key? key, required this.text, required this.role, required this.id}) : super(key: key);
  final String text;
  final String role;
  final String id;

  @override
  State<PostSuccess> createState() => _PostSuccessState();
}

class _PostSuccessState extends State<PostSuccess> {
  bool? home;

  void setHome() async{
    final prefs = await SharedPreferences.getInstance();
    home = prefs.getBool('superAdmin');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setHome();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => openDialog(context) as Future<bool>,
      child: Scaffold(
        body: ListView(
          children: [
            const SizedBox(height: 30,),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Image.asset('images/success.png'),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(widget.text, style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
              ),
                textAlign: TextAlign.center,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Home(role: widget.role, id: widget.id))),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.blueAccent
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Align(
                        alignment: Alignment.center,
                        child: Text('Home', style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),)
                    ),
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
  Future openDialog(BuildContext context) {
    void yes() => SystemNavigator.pop();
    void no() => Navigator.pop(context);
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Do you wish to Logout'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buttons(color: Colors.green, text: 'No', func: no),
              buttons(color: Colors.red, text: 'Yes', func: yes),
            ],
          ),
        ));
  }
}
