import 'package:african_springs/api_files.dart';
import 'package:african_springs/pages/post_success.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:string_capitalize/string_capitalize.dart';

import '../home/home.dart';

class SingleGeneral extends StatefulWidget {
  const SingleGeneral(
      {Key? key, this.post, required this.role, required this.id})
      : super(key: key);
  final dynamic post;
  final String role;
  final String id;

  @override
  State<SingleGeneral> createState() => _SingleGeneralState();
}

class _SingleGeneralState extends State<SingleGeneral> {
  bool isLoading = false;
  bool isStatus = false;
  bool isSwitch = false;
  bool? isActive;

  TextEditingController? news;
  TextEditingController? title;
  TextEditingController? author;
  TextEditingController? link;
  String? category;
  String? id;
  final dio = Dio();
  bool isProfileLoading = false;
  bool isDeleteLoading = false;

  void showAlert() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text(
              'Do you wish to delete this post?',
              textAlign: TextAlign.center,
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () => deletePost(),
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green)),
                ),
              ],
            ),
          ));

  void deletePost() async {
    setState(() => isDeleteLoading = true);
    Response response = await dio.delete(LiveApis.deletePost + id!);
    if (response.statusCode != 200) {
      setState(() => isDeleteLoading = false);
      return;
    }

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostSuccess(
                  text: 'Post Deleted Successfully',
                  role: widget.role,
                  id: widget.id,
                )));
  }

  void changeStatus() async {
    setState(() => isStatus = true);
    Response response = await dio.patch(LiveApis.updateStatus + id!,
        data: {'active': !widget.post['active']});
    if (response.statusCode == 200) {
      setState(() {
        isStatus = false;
        widget.post['active'] = !widget.post['active'];
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Home(
                    role: widget.role,
                    id: widget.id,
                  )));
    } else {
      setState(() => isStatus = false);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    news = TextEditingController(text: widget.post['news']);
    title = TextEditingController(text: widget.post['title']);
    author = TextEditingController(text: widget.post['author']);
    link = TextEditingController(text: widget.post['link']);
    isActive = !widget.post['active'];
    category = widget.post['category'].toString().capitalizeEach();
    id = widget.post['_id'];
  }

  @override
  Widget build(BuildContext context) {
    // TextEditingController nameController =
    //     TextEditingController(text: widget.post['author']);
    TextEditingController dateController =
        TextEditingController(text: widget.post['date']);

    return Scaffold(
      body: ListView(
        children: [
          Stack(children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .4,
              width: MediaQuery.of(context).size.width,
              child: isProfileLoading
                  ? const Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator())
                  : Image.network(
                      widget.post['thumbnail'],
                      fit: BoxFit.cover,
                    ),
            ),
          ]),
          SizedBox(
            height: 40,
            child: Align(
              alignment: Alignment.center,
              child: isActive!
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 16,
                          width: 16,
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Active',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        )
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 16,
                          width: 16,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'In Active',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                TextFormField(
                  controller: news,
                  readOnly: true,
                  maxLines: 10,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Your Story'),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: title,
                  readOnly: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter News Title'),
                ),
                const SizedBox(
                  height: 20,
                ),

                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () => showAlert(),
                    child: isDeleteLoading
                        ? const CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          )
                        : const Text(
                            'Delete Post',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 15))),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                isActive!
                    ? activeBtn(text: 'Deactivate', color: Colors.red)
                    : activeBtn(text: 'Activate', color: Colors.green),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: author,
                  readOnly: true,
                  // readOnly: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Author'),
                ),
                const SizedBox(
                  height: 20,
                ),
                // widget.post['link']?.isEmpty ? const SizedBox() : TextFormField(
                //   controller: link,
                //   // readOnly: true,
                //   decoration: const InputDecoration(
                //       border: OutlineInputBorder(), hintText: 'Edit YouTube Link'),
                // ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Date'),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> buildMenuCategory(String category) =>
      DropdownMenuItem(
        value: category,
        child: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      );

  Widget activeBtn({required String text, required Color color}) {
    return GestureDetector(
      onTap: () => changeStatus(),
      child: Container(
        decoration: BoxDecoration(color: color),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Align(
              alignment: Alignment.center,
              child: isStatus
                  ? const CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    )
                  : Text(
                      text,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )),
        ),
      ),
    );
  }

  Widget toggleSwitch(Function switchIt, int i) {
    return isSwitch
        ? const CircularProgressIndicator(
            backgroundColor: Colors.green,
            color: Colors.red,
          )
        : ToggleSwitch(
            key: GlobalKey(),
            minWidth: 70.0,
            cornerRadius: 20.0,
            activeBgColors: [
              [Colors.green[800]!],
              [Colors.red[800]!]
            ],
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.white,
            initialLabelIndex: i,
            totalSwitches: 2,
            labels: const ['True', 'False'],
            radiusStyle: true,
            onToggle: (index) => switchIt(),
          );
  }
}
