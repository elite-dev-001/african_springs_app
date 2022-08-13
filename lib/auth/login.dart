import 'dart:convert';
import 'dart:io';
import 'package:african_springs/auth/forget_password.dart';
// import 'package:african_springs/home/admin_home.dart';
import 'package:african_springs/home/home.dart';
// import 'package:african_springs/home/super_admin_home.dart';
// import 'package:african_springs/pages/suspend.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_text_form_field/flutter_text_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_files.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoading = false;
  var errs = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final dio = Dio();

  //Set Error Messages
  void setErr(String err) => setState(() => errs = err);

  //Login Agent Account
  void submit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setErr('Both fields are required');
    } else if (!_emailController.text.contains('@')) {
      setErr('Invalid Email Address');
    } else {
      setErr('');
      setState(() => isLoading = true);
      Response response = await dio.post(LiveApis.login, data: {
        'email': _emailController.text,
        'password': _passwordController.text
      });
      debugPrint(response.data.toString());
      if (response.data["status"] == "ok") {
        final role = response.data["role"];
        final t = response.data["data"];
        final token = t.split(".")[1];
        List<int> res = base64.decode(base64.normalize(token));
        final adminData = jsonDecode(utf8.decode(res));
        debugPrint(adminData.toString());
        final id = adminData["id"];
        // // print(id);
        getAdmin(t, id, role);
      } else {
        setErr(response.data["error"]);
        setState(() => isLoading = false);
      }
    }
  }

  //Get Single Admin
  void getAdmin(String token, String id, String role) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('id', id);
    final dio = Dio(BaseOptions(
        baseUrl: LiveApis.liveApi,
        responseType: ResponseType.json,
        contentType: ContentType.json.toString()));

    dio.options.headers["Authorization"] = "Bearer $token";
    var response = role == 'admin'
        ? await dio.get(LiveApis.getAdmin + id)
        : await dio.get(LiveApis.getSuperAdmin + id);
    if (response.statusCode != 200) return;
    prefs.setBool('superAdmin', false);

    // response.data[0]['suspend']
    //     ? Navigator.push(
    //         context, MaterialPageRoute(builder: (context) => const Suspend()))
    //     :
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Home(
                      role: role,
                      id: id,
                    )));

    await prefs.setString('data', json.encode(response.data[0]));
    await prefs.setString('token', token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          SizedBox(
              height: MediaQuery.of(context).size.height * .35,
              child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'images/login.png',
                    // width: 500,
                  ))),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20.0)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18.0,
                        ),
                        child: CustomTextField(
                          _emailController,
                          hint: 'Email',
                          password: false,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 0.0,
                        ),
                        child: CustomTextField(
                          _passwordController,
                          hint: 'Password',
                          password: true,
                          obscure: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => const ForgetPassword(),
                            child: const Text(
                              'Forget Password?',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: () => submit(),
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                ),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(vertical: 10))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          errs,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 17),
                        ),
                      )
                    ],
                  ),
                )),
          )
        ],
      ),
    );
  }
}

/*else if (response.data["status"] == "ok" &&
          response.data["role"] == 'superadmin') {
        final t = response.data["data"];
        final token = t.split(".")[1];
        List<int> res = base64.decode(base64.normalize(token));
        final superAdminData = jsonDecode(utf8.decode(res));
        debugPrint(superAdminData);
        final id = superAdminData["id"];
        // // print(id);
        getSuperAdmin(t, id);
      } */

/*  //Get Single Super Admin
  void getSuperAdmin(String token, String id) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('id', id);
    final dio = Dio(BaseOptions(
        baseUrl: LiveApis.liveApi,
        responseType: ResponseType.json,
        contentType: ContentType.json.toString()));

    dio.options.headers["Authorization"] = "Bearer $token";
    var response = await dio.get(LiveApis.getSuperAdmin + id);
    if (response.statusCode != 200) return;
    prefs.setBool('superAdmin', true);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SuperAdminHome()));

    await prefs.setString('data', json.encode(response.data[0]));
    await prefs.setString('token', token);
  }*/
