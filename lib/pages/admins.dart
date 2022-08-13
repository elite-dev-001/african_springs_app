// import 'package:african_springs/pages/single_post.dart';
import 'package:african_springs/pages/new_admin.dart';
import 'package:african_springs/pages/single_admin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../api_files.dart';
import '../navigation.dart';

class Admins extends StatefulWidget {
  const Admins({Key? key, required this.role, required this.id})
      : super(key: key);
  final String role;
  final String id;

  @override
  State<Admins> createState() => _AdminsState();
}

class _AdminsState extends State<Admins> {
  bool isLoading = false;
  final dio = Dio();
  List allAdmins = [];

  void addNewAdmin() => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NewAdmin(
                role: widget.role,
                id: widget.id,
              )));

  void getAdmins() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final dio = Dio(BaseOptions(
        baseUrl: LiveApis.liveApi,
        responseType: ResponseType.json,
        contentType: ContentType.json.toString()));

    dio.options.headers["Authorization"] = "Bearer $token";
    var response = await dio.get(LiveApis.getAllAdmin);
    if (response.statusCode == 200) {
      setState(() => isLoading = false);
      allAdmins = response.data['results'];
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAdmins();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => openDialog(context) as Future<bool>,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => addNewAdmin(),
        ),
        appBar: AppBar(
          centerTitle: true,
          title: const Text('All Admins'),
          backgroundColor: Colors.blue.shade700,
        ),
        drawer: NavigationDrawer(
          role: widget.role,
          id: widget.id,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : allAdmins.isEmpty
                ? const Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 38.0),
                      child: Text(
                        'No Admin Yet.',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: ListView(
                      children: allAdmins
                          .map((admin) => userList(
                              context,
                              '${admin['firstName']} ${admin['lastName']}',
                              admin['email'],
                              admin['profile'],
                              admin['suspend'],
                              admin,
                              widget.role,
                              widget.id))
                          .toList()
                          .reversed
                          .toList(),
                    ),
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

Widget userList(BuildContext context, String name, String email, String img,
    bool suspend, Object admin, String role, String id) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Container(
      decoration: BoxDecoration(
          border: Border.all(), borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: !suspend
              ? [
                  Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  const Text(
                    'Active',
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  )
                ]
              : [
                  Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  const Text(
                    'Suspended',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  )
                ],
        ),
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
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SingleAdmin(
                      user: admin,
                      role: role,
                      id: id,
                    ))),
        contentPadding: const EdgeInsets.all(6),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(img),
        ),
      ),
    ),
  );
}
