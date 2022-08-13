import 'package:african_springs/pages/single_users.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../api_files.dart';
import '../navigation.dart';


class Users extends StatefulWidget {
  const Users({Key? key, required this.role, required this.id}) : super(key: key);
  final String role;
  final String id;

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  bool isLoading = false;
  final dio = Dio();
  List allUsers = [];

  void getUsers() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final dio = Dio(BaseOptions(
        baseUrl: LiveApis.liveApi,
        responseType: ResponseType.json,
        contentType: ContentType.json.toString()));

    dio.options.headers["Authorization"] = "Bearer $token";
    var response = await dio.get(LiveApis.getAllUsers);
    if (response.statusCode != 200) return;
    setState(() => isLoading = false);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUsers();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => openDialog(context) as Future<bool>,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('All Users'),
          backgroundColor: Colors.blue.shade700,
        ),
        drawer: NavigationDrawer(
          role: widget.role,
          id: widget.id,
        ),
        body: isLoading ? const Center( child: CircularProgressIndicator(),) : allUsers.isEmpty
            ? const Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 38.0),
            child: Text(
              'No User Yet.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(25.0),
          child: ListView(
            children: allUsers
                .map((user) => userList(context,'${user['firstName']} ${user['lastName']}',user['email'],user))
                .toList().reversed.toList(),
          ),
        ),
      ),
    );
  }
  Future openDialog(BuildContext context) {
    void yes() =>  SystemNavigator.pop();
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


Widget userList(BuildContext context, String name, String email, Object user) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Container(
      decoration: BoxDecoration(
          border: Border.all(), borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text(
            email,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SingleUser(user: user))),
        contentPadding: const EdgeInsets.all(6),
        leading: const CircleAvatar(
          radius: 30,
          child: Icon(Icons.person),
        ),
      ),
    ),
  );

}