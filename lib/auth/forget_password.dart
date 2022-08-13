import 'dart:convert';

import 'package:african_springs/api_files.dart';
import 'package:african_springs/auth/login.dart';
// import 'package:african_springs/pages/post_success.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _controller = TextEditingController();
  String? token;
  String? email;
  String? id;
  String err = '';
  bool isLoading = false;

  void setErr(String error) => setState(() => err = error);

  void reset() async{
    if(_controller.text.isEmpty) {
      setErr('Field is required');
    } else if(_controller.text.length < 6) {
      setErr('Password should be more than 6 characters');
    } else {
      final data = {
        "newPassword": _controller.text,
        "token": token,
        "email": email
      };
      setState(() => isLoading = true);
      Response response = await Dio().post(LiveApis.resetPassword+id!, data: data);
      if(response.statusCode == 200) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
      } else {
        setErr('Could not reset password, Try Again');
      }
    }
  }

  void getData() async{
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    final data = json.decode(prefs.getString('data')!);
    email = data['email'];
    id = data['_id'];
  }

  @override
  initState() {
    super.initState();
    getData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Reset'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 60),
        child: ListView(
          children: [
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter your new password',
                  border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 20,),
            GestureDetector(
              onTap: () => reset(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                decoration: const BoxDecoration(
                    color: Colors.green
                ),
                child: Align(
                    alignment: Alignment.center,
                    child: isLoading ? const CircularProgressIndicator() : const Text('Reset Password', style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),)
                ),
              ),
            ),
            const SizedBox(height: 20,),
            Text(err, textAlign: TextAlign.center, style: const TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.w700
            ),)
          ],
        ),
      ),
    );
  }
}
