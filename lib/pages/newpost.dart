import 'package:african_springs/pages/post_success.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_text_form_field/flutter_text_form_field.dart';
// import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../navigation.dart';

import '../api_files.dart';

class NewPost extends StatefulWidget {
  const NewPost({Key? key, required this.role, required this.id}) : super(key: key);
  final String role;
  final String id;

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  // final String date = DateFormat().add_yMMMMEEEEd().format(DateTime.now());
  TextEditingController title = TextEditingController();
  TextEditingController news = TextEditingController();
  TextEditingController link = TextEditingController();
  TextEditingController otherLink = TextEditingController();
  final cloudinary =
      Cloudinary('156174746686461', '4WyQo0sdAmR6Jo1FOzOoAunv5YM', 'dhejdjq9l');

  final categories = [
    'Health',
    'Sport',
    'Entertainment',
    'Education',
    'News',
    'Travel',
    'LifeStyle',
    'Science',
    'Business',
    'Fashion',
    'Food',
    'Documentary',
    'Culture',
    'Article',
    'Motivation',
    'Newspaper Headlines',
    'Technology',
    'Trends',
    'Politics',
    'News Update',
    'World',
    'Cinema Box Office',
    'Markets',
    'Features',
    'Property',
    'Business Leaders',
    'Medical Research',
    'Healthy Living',
    'Music News',
    'Celebrity News',
    'Religion',
    'Global Economy',
    'Conflicts',
    'CryptoCurrency',
    'Vlog',
    'African Tradition'
  ];

  final dio = Dio();
  String? name;
  String id = '';
  String? profile;

  String? file;
  String? file2;
  String status = "No file Picked";
  String status2 = "No file Picked";
  String err = '';
  String sizeErr = '';
  String sizeErr2 = '';
  bool isLoading = false;
  String? category;

  void getData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.decode(prefs.getString('data')!);
    setState(() => name = '${data['firstName']} ${data['lastName']}');
    id = data['_id'];
    profile = data['profile'];
  }

  void setErr(String res) => setState(() => err = res);

  void fileStatus() {
    setState(() {
      status = file == null ? 'No file picked' : 'One File Picked';
    });
  }
  void fileStatus2() {
    setState(() {
      status2 = file2 == null ? 'No file picked' : 'One File Picked';
    });
  }

  bool emptyField() {
    if (news.text.isEmpty ||
        title.text.isEmpty ||
        category!.isEmpty ||
        file == null) {
      setErr('All fields are Required');
      return false;
    } else {
      return true;
    }
  }

  void submit() async {
    CloudinaryResponse? cResponse2;
    if (emptyField()) {
      setState(() => isLoading = true);
      final cResponse = await cloudinary.uploadFile(
        filePath: file,
        resourceType: CloudinaryResourceType.image,
      );
      if(file2 != null){
        cResponse2 = await cloudinary.uploadFile(
          filePath: file2,
          resourceType: CloudinaryResourceType.image,
        );
      }

      var formData = {
        'category': category,
        'title': title.text,
        'author': name,
        'news': news.text,
        // 'date': date,
        'posterId': id,
        'posterImage': profile,
        'link': link.text,
        'videoLink': otherLink.text,
        'thumbnail': cResponse.secureUrl,
        'thumbnail2': file2 != null ? cResponse2?.secureUrl : ''
      };

      Response response = await dio.post(LiveApis.createPost, data: formData);
      if (response.statusCode == 200) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PostSuccess(
                      text: 'Post Added Successfully', role: widget.role, id: widget.id,
                    )));
        // setState(() => isLoading = false);
      } else {
        setErr('Could not Post, something went wrong');
      }
    }
  }

  double checkImageSize(int size) => 0.0009765625 * (size / 1024);

  void uploadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final int size = result.files.first.size;
      debugPrint(size.toString());
      debugPrint(checkImageSize(size).toString());
      if (checkImageSize(size) > 4.0) {
        setState(() => sizeErr = 'Image must be less than 4MB');
      } else {
        setState(() => sizeErr = '');
        file = result.files.first.path;
        fileStatus();
      }
    } else {
      fileStatus();
    }
  }
  void uploadImage2() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final int size = result.files.first.size;
      debugPrint(size.toString());
      debugPrint(checkImageSize(size).toString());
      if (checkImageSize(size) > 4.0) {
        setState(() => sizeErr2 = 'Image must be less than 4MB');
      } else {
        setState(() => sizeErr2 = '');
        file2 = result.files.first.path;
        fileStatus2();
      }
    } else {
      fileStatus2();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    // TextEditingController dateController = TextEditingController(text: date);
    TextEditingController nameController = TextEditingController(text: name);

    return WillPopScope(
      onWillPop: () => openDialog(context) as Future<bool>,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add New Post'),
        ),
        drawer: NavigationDrawer(role: widget.role, id: widget.id,),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 0.0,
                ),
                child: Column(children: [
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: news,
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
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter News Title'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: link,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Only Youtube Link (Optional)'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: otherLink,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Any other Link (Optional)'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 1)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: category,
                        hint: const Text(
                          'Category',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        iconSize: 36,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.black),
                        isExpanded: true,
                        items: categories.map(buildMenuCategory).toList(),
                        onChanged: (value) => setState(() => category = value),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: nameController,
                    // readOnly: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), hintText: 'Author'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // TextFormField(
                  //   controller: dateController,
                  //   readOnly: true,
                  //   decoration: const InputDecoration(
                  //       border: OutlineInputBorder(), hintText: 'Date'),
                  // ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  children: [
                    const Text('Image must be less than 4MB'),
                    SizedBox(
                      child: Align(
                        child: GestureDetector(
                          onTap: () => uploadImage(),
                          child: Container(
                            decoration: BoxDecoration(border: Border.all()),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 5),
                              child: Text(
                                'Select News Image',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        sizeErr,
                        style: const TextStyle(fontSize: 20, color: Colors.red),
                      ),
                    ),
                    Center(
                        child: Text(
                      status,
                      style: TextStyle(
                          fontSize: 17,
                          color: file == null ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ),
              // const SizedBox(
              //   height: 20,
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: Column(
                  children: [
                    const Text('Image must be less than 4MB'),
                    SizedBox(
                      child: Align(
                        child: GestureDetector(
                          onTap: () => uploadImage2(),
                          child: Container(
                            decoration: BoxDecoration(border: Border.all()),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 5),
                              child: Text(
                                'Select Another Optional Image',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        sizeErr2,
                        style: const TextStyle(fontSize: 20, color: Colors.red),
                      ),
                    ),
                    Center(
                        child: Text(
                          status2,
                          style: TextStyle(
                              fontSize: 17,
                              color: file2 == null ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => submit(),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(color: Colors.blueAccent),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Align(
                        alignment: Alignment.center,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              )
                            : const Text(
                                'Submit',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              )),
                  ),
                ),
              ),
              // const SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    err,
                    style: const TextStyle(
                        fontSize: 17,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
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

  DropdownMenuItem<String> buildMenuCategory(String category) =>
      DropdownMenuItem(
        value: category,
        child: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      );
}

Widget form(
    {required String hintText, required TextEditingController controller}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: CustomTextField(
      controller,
      hint: hintText,
      password: false,
      keyboardType: hintText.toLowerCase() == 'phone number'
          ? TextInputType.phone
          : TextInputType.text,
    ),
  );
}
