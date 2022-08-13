import 'package:african_springs/api_files.dart';
import 'package:african_springs/pages/newpost.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../navigation.dart';
import '../pages/single_post.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.role, required this.id})
      : super(key: key);
  final String role;
  final String id;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = false;
  List? allPost;

  void setLoading(bool value) => setState(() => isLoading = value);

  void getAllPost() async {
    setLoading(true);
    Response response = await Dio().get(LiveApis.getAllPost);
    if (response.statusCode != 200) return;
    allPost = response.data['results'];
    allPost?.retainWhere((element) => element['posterId'] == widget.id);
    setLoading(false);
  }

  @override
  void initState() {
    super.initState();
    getAllPost();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => openDialog(context) as Future<bool>,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      NewPost(role: widget.role, id: widget.id))),
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          centerTitle: true,
          title: const Text('My Posts'),
          backgroundColor: Colors.blue.shade700,
        ),
        drawer: NavigationDrawer(
          role: widget.role,
          id: widget.id,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : allPost!.isEmpty
                ? const Center(
                    child: Text(
                      'No Post Yet. Click on the plus icon to add a new Post',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView(
                      children: allPost!
                          .map((post) => postList(
                              context,
                              post['title'],
                              post['date'],
                              post['thumbnail'],
                              post['active'],
                              post,
                              widget.role,
                              widget.id))
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

Widget postList(BuildContext context, String title, String author, String img,
    bool active, Object post, String role, String id) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Container(
      decoration: BoxDecoration(
          border: Border.all(), borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: active
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
                    'InActive',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  )
                ],
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text(
            author,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SinglePost(
                      post: post,
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
