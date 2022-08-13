import 'package:african_springs/pages/single_general.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../navigation.dart';
import '../api_files.dart';

class General extends StatefulWidget {
  const General({Key? key, required this.role, required this.id})
      : super(key: key);
  final String role;
  final String id;

  @override
  State<General> createState() => _GeneralState();
}

class _GeneralState extends State<General> {
  bool isLoading = false;
  final dio = Dio();
  List allPosts = [];

  void getPosts() async {
    setState(() => isLoading = true);

    Response response =
        await dio.get('${LiveApis.getAllPost}?category=general');
    // print(response.data);
    if (response.statusCode == 200) {
      setState(() => isLoading = false);
      allPosts = response.data['results'];
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => openDialog(context) as Future<bool>,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('All Posts'),
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
            : allPosts.isEmpty
                ? const Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 38.0),
                      child: Text(
                        'No Post Yet.',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: ListView(
                      children: allPosts
                          .map((post) => postList(
                              context,
                              post['title'],
                              post['date'],
                              post['thumbnail'],
                              post['active'],
                              post,
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
          children: !active
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
                builder: (context) => SingleGeneral(
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
