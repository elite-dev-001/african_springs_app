import 'package:african_springs/api_files.dart';
import 'package:african_springs/home/home.dart';
import 'package:african_springs/pages/post_success.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:string_capitalize/string_capitalize.dart';


class SinglePost extends StatefulWidget {
  const SinglePost({Key? key, this.post, required this.role, required this.id}) : super(key: key);
  final dynamic post;
  final String role;
  final String id;

  @override
  State<SinglePost> createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {
  // bool isSuper = false;
  bool isLoading = false;
  bool isStatus = false;
  bool isSwitch = false;
  int? index;
  int? featuredIndex;

  final categories = [
    'Health',
    'Education',
    'News',
    'Sport',
    'Entertainment',
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
  TextEditingController? news;
  TextEditingController? title;
  TextEditingController? author;
  TextEditingController? link;
  String? category;
  String? id;
  final dio = Dio();
  bool isProfileLoading = false;
  bool isDeleteLoading = false;

  final cloudinary = Cloudinary(
      '156174746686461', '4WyQo0sdAmR6Jo1FOzOoAunv5YM', 'dhejdjq9l');

  void uploadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() => isProfileLoading = true);
      final file = result.files.first.path;
      final cResponse = await cloudinary.uploadFile(
        filePath: file,
        resourceType: CloudinaryResourceType.image,
      );
      Response response = await dio.patch(LiveApis.updateThumbnail + id!,
          data: {'thumbnail': cResponse.secureUrl});
      if (response.statusCode != 200) {
        setState(() => isLoading = false);
        return;
      }
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PostSuccess(
                    text: 'Post Picture Changed Successfully', role: widget.role, id: widget.id,
                  )));
    }
  }

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
              text: 'Post Deleted Successfully', role: widget.role, id: widget.id,
            )));
  }

  // void setPost() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     isSuper = prefs.getBool('superAdmin')!;
  //   });
  // }

  void submit() async {
    if (news!.text.isNotEmpty &&
        title!.text.isNotEmpty &&
        category!.isNotEmpty) {
      setState(() => isLoading = true);
      Response response = await dio.patch(LiveApis.updatePost + id!, data: {
        'category': category,
        'title': title!.text,
        'news': news!.text,
        'author': author!.text,
        'link': link!.text
      });
      if (response.statusCode == 200) {
        setState(() => isLoading = false);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PostSuccess(
                  text: 'Post Updated Successfully', role: widget.role, id: widget.id,
                )));
      }
    }
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
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => Home(role: widget.role, id: widget.id)));
    } else {
      setState(() => isStatus = false);
    }
  }

  void switchIt() async {
    setState(() => isSwitch = true);
    Response response = await dio.patch(LiveApis.updateTrending + id!,
        data: {"trending": !widget.post['trending']});
    if (response.statusCode == 200) {
      setState(() {
        isSwitch = false;
        widget.post['trending'] = !widget.post['trending'];
        widget.post['trending'] ? index = 0 : index = 1;
      });
    } else {
      setState(() => isSwitch = false);
    }
  }

  void switchFeatured() async {
    setState(() => isSwitch = true);
    Response response = await dio.patch(LiveApis.updateFeatured + id!,
        data: {"featured": !widget.post['featured']});
    if (response.statusCode == 200) {
      setState(() {
        isSwitch = false;
        widget.post['featured'] = !widget.post['featured'];
        widget.post['featured'] ? featuredIndex = 0 : featuredIndex = 1;
      });
    } else {
      setState(() => isSwitch = false);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // setPost();
    news = TextEditingController(text: widget.post['news']);
    title = TextEditingController(text: widget.post['title']);
    author = TextEditingController(text: widget.post['author']);
    link = TextEditingController(text: widget.post['link']);
    category = widget.post['category'].toString().capitalizeEach();
    id = widget.post['_id'];
    index = widget.post['trending'] ? 0 : 1;
    featuredIndex = widget.post['featured'] ? 0 : 1;
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
            Positioned(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => uploadImage(),
                  icon: const Icon(Icons.edit),
                ),
              ),
            )
          ]),
          SizedBox(
            height: 40,
            child: Align(
              alignment: Alignment.center,
              child: widget.post['active']
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
                      onChanged: (value) => setState(() => category = value!.toLowerCase()),
                    ),
                  ),
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
                        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15))
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                widget.role == 'superadmin'
                    ? widget.post['active']
                        ? activeBtn(text: 'Deactivate', color: Colors.red)
                        : activeBtn(text: 'Activate', color: Colors.green)
                    : const SizedBox(
                        height: 0,
                      ),
                const SizedBox(
                  height: 20,
                ),
                widget.role == 'superadmin'
                    ? SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Trending',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            toggleSwitch(switchIt, index!)
                          ],
                        ),
                      )
                    : const SizedBox(
                        height: 0,
                      ),
                const SizedBox(
                  height: 20,
                ),
                widget.role == 'superadmin'
                    ? SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Featured',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            toggleSwitch(switchFeatured, featuredIndex!)
                          ],
                        ),
                      )
                    : const SizedBox(
                        height: 0,
                      ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: author,
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
                ),
                widget.post['active']
                    ? GestureDetector(
                        onTap: () => submit(),
                        child: Container(
                          decoration:
                              const BoxDecoration(color: Colors.blueAccent),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Align(
                                alignment: Alignment.center,
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        backgroundColor: Colors.white,
                                      )
                                    : const Text(
                                        'Update Post',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      )),
                          ),
                        ),
                      )
                    : const Text(
                        'This News is Not Active',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
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
