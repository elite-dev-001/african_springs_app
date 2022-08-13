import 'dart:convert';

import 'package:african_springs/pages/admins.dart';
import 'package:african_springs/pages/all_post.dart';
import 'package:african_springs/pages/general.dart';
import 'package:african_springs/pages/new_admin.dart';
import 'package:african_springs/pages/newpost.dart';
import 'package:african_springs/pages/post_success.dart';
import 'package:african_springs/pages/profile.dart';
import 'package:african_springs/pages/reset_password.dart';
import 'package:african_springs/pages/users.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_files.dart';
import 'home/home.dart';


class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({
    Key? key, required this.role, required this.id,
  }) : super(key: key);
  final String role;
  final String id;

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  String picture = '';
  String name = '';
  final dio = Dio();
  bool isLoading = false;

  final cloudinary = Cloudinary(
      '156174746686461', '4WyQo0sdAmR6Jo1FOzOoAunv5YM', 'dhejdjq9l');

  void uploadImage() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('id')!;
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = result.files.first.path;
      final cResponse = await cloudinary.uploadFile(
        filePath: file,
        resourceType: CloudinaryResourceType.image,
      );
      Response response = await dio.patch(LiveApis.resetSuperImage + id,
          data: {'profile': cResponse.secureUrl});
      if(response.statusCode != 200) {setState(() => isLoading = false); return;}
      Navigator.push(context, MaterialPageRoute(builder: (context) => PostSuccess(text: 'Profile Picture Changed Successfully', role: widget.role, id: widget.id,)));
    }
  }

  void getData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.decode(prefs.getString('data')!);
    setState(() => picture = data['profile']);
    setState(() => name = '${data['firstName']} ${data['lastName']}');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) => Drawer(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildHeader(
            context,
          ),
          buildMenuItems(context)
        ],
      ),
    ),
  );

  Widget buildHeader(BuildContext context) => Material(
    color: Colors.blue.shade700,
    child: InkWell(
      onTap: () {
        Navigator.pop(context);

        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Profile()));
      },
      child: Container(
        padding: EdgeInsets.only(
            top: 24 + MediaQuery.of(context).padding.top, bottom: 24),
        child: Column(
          children: [
            picture.isEmpty
                ? const Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(backgroundColor: Colors.white,),
            )
                : isLoading ? const CircularProgressIndicator(backgroundColor: Colors.white,) : Stack(
              children: [
                CircleAvatar(
                  radius: 62,
                  backgroundImage: NetworkImage(picture),
                ),
                Positioned(
                  top: 70,
                  left: 80,
                  child: IconButton(
                      onPressed: () =>uploadImage(),
                      icon: const Icon(
                        Icons.mode_edit_outline_rounded,
                        size: 30,
                      )),
                )
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              name,
              style: const TextStyle(fontSize: 28, color: Colors.white),
            ),
            // const Text(
            //   'wilsonchinedu001@gmail.com',
            //   style: TextStyle(fontSize: 16, color: Colors.white),
            // ),
          ],
        ),
      ),
    ),
  );

  Widget buildMenuItems(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        runSpacing: 16,
        children: [
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('HOME'),
            onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => Home(role: widget.role, id: widget.id,))),
          ),
          widget.role == 'superadmin' ? ListTile(
            leading: const Icon(Icons.newspaper),
            title: const Text('All POSTS'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AllPost(role: widget.role, id: widget.id,)));
            },
          ) : const SizedBox(height: 0,),
          ListTile(
            leading: const Icon(Icons.public),
            title: const Text('GENERAL'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => General(role: widget.role, id: widget.id,)));
            },
          ),
          widget.role == 'superadmin' ? ListTile(
            leading: const Icon(Icons.people),
            title: const Text('USERS'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Users(role: widget.role, id: widget.id,)));
            },
          ) : const SizedBox(height: 0,),
          widget.role == 'superadmin' ? ListTile(
            leading: const Icon(Icons.nature_people_rounded),
            title: const Text('ADMINS'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => Admins(role: widget.role, id: widget.id,))),
          ) : const SizedBox(height: 0,),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('ADD POST'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => NewPost(role: widget.role, id: widget.id,))),
          ),
          widget.role == 'superadmin' ? ListTile(
            leading: const Icon(Icons.person_add_alt_1),
            title: const Text('ADD ADMIN'),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => NewAdmin(role: widget.role, id: widget.id,))),
          ) : const SizedBox(height: 0,),
          const Divider(
            thickness: 2.0,
          ),
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text('RESET PASSWORD'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => ResetPassword(role: widget.role, id: widget.id,))),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('SIGN OUT'),
            onTap: () => openDialog(context),
          ),
        ],
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

Widget buttons(
    {required Color color, required String text, required Function func}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25.0),
    child: GestureDetector(
      onTap: () => func(),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        decoration: BoxDecoration(color: color),
      ),
    ),
  );
}