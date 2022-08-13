// import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:african_springs/pages/post_success.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_text_form_field/flutter_text_form_field.dart';
import '../navigation.dart';
import '../api_files.dart';

class NewAdmin extends StatefulWidget {
  const NewAdmin({Key? key, required this.role, required this.id}) : super(key: key);
  final String role;
  final String id;

  @override
  State<NewAdmin> createState() => _NewAdminState();
}

class _NewAdminState extends State<NewAdmin> {
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  final dio = Dio();
  final cloudinary = Cloudinary('147132482297155', 'TuC__zwwBXQ764YO3Y_vXr73p00', 'wilsonchinedu');

  Gender _gender = Gender.male;
  String? file;
  String status = "No file Picked";
  String err = '';
  bool isLoading = false;


  void setErr(String res) => setState(() => err = res);

  void fileStatus() {
    setState(() {
      status = file == null ? 'No file picked' : 'One File Picked';
    });
  }


  bool emptyField() {
    final controllers = [firstName.text, lastName.text, city.text, country.text, email.text, password.text, confirmPassword.text];
    bool value = false;
    for(var controller in controllers) {
      if(controller.isEmpty) {
        setErr('All fields are Required');
        value = false;
        break;
      } else {
        setErr('');
        value = true;
      }
    }
    return value;
  }

  void submit() async{
    setState(() => isLoading = true);
    if(emptyField() && file != null) {
      final cResponse = await cloudinary.uploadFile(
        filePath: file,
        resourceType: CloudinaryResourceType.image,
      );

      var data = {
        'firstName': firstName.text,
        'lastName': lastName.text,
        'gender': _gender.toString(),
        'city': city.text,
        'country': country.text,
        'email': email.text,
        'profile': cResponse.secureUrl,
        'password': password.text,
        'confirmPassword': confirmPassword.text
      };

      Response response = await dio.post(LiveApis.createAdmin, data: data);

      if(response.statusCode == 200) {
        setState(() => isLoading = false);
        Navigator.push(context, MaterialPageRoute(builder: (context) => PostSuccess(text: 'Admin Created Successfully', role: widget.role, id: widget.id,)));
      } else {
        setErr('Something went wrong. Could not create');
        setState(() => isLoading = false);
      }
    }
  }

  void uploadImage() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if(result != null) {
      file = result.files.first.path;
      fileStatus();
    } else {
      fileStatus();
    }
  }


  @override
  Widget build(BuildContext context) {
    final formData = [
      {
        "hintText": "First Name",
        "controller": firstName,
      },
      {
        "hintText": "Last Name",
        "controller": lastName,
      },
      {
        "hintText": "City",
        "controller": city,
      },
      {
        "hintText": "Country",
        "controller": country,
      },
      {
        "hintText": "Email",
        "controller": email,
      },
      {
        "hintText": "Password",
        "controller": password,
      },
      {
        "hintText": "Confirm Password",
        "controller": confirmPassword,
      },
    ];
    return WillPopScope(
      onWillPop: () => openDialog(context) as Future<bool>,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add New Admin'),
        ),
        drawer: NavigationDrawer(role: widget.role, id: widget.id,),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Center(
                  child: Text(err, style: const TextStyle(
                      fontSize: 17,
                      color: Colors.red,
                      fontWeight: FontWeight.bold
                  ),),
                ),
              ),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0,),
                child: Column(
                  children: formData
                      .map((e) => form(
                      hintText: e["hintText"].toString(),
                      controller: e["controller"] as TextEditingController))
                      .toList(),
                ),
              ),
              SizedBox(
                child: Column(
                  children: [
                    const Text('Gender', style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                    ),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Text('Male', style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16
                            ),),
                            Radio(value: Gender.male, groupValue: _gender, onChanged: (Gender? value) {
                              setState(() {
                                _gender = value!;
                              });
                            })
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Female', style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16
                            ),),
                            Radio(value: Gender.female, groupValue: _gender, onChanged: (Gender? value) {
                              setState(() {
                                _gender = value!;
                              });
                            })
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: SizedBox(
                  child: Align(
                    child: GestureDetector(
                      onTap: () => uploadImage(),
                      child: Container(
                        decoration: BoxDecoration(border: Border.all()),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                          child: Text('Select Admin Image', style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                          ),),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Center(child: Text(status, style: TextStyle(
                  fontSize: 17,
                  color: file == null ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold
              ),)),
              const SizedBox(height: 20,),
              GestureDetector(
                onTap: () => submit(),
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.blueAccent
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Align(
                        alignment: Alignment.center,
                        child: isLoading ? const CircularProgressIndicator(backgroundColor: Colors.white,) : const Text('Submit', style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),)
                    ),
                  ),
                ),
              )
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

enum Gender{ male, female}