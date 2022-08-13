import 'package:african_springs/pages/admins.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:african_springs/api_files.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SingleAdmin extends StatefulWidget {
  const SingleAdmin(
      {Key? key, required this.user, required this.role, required this.id})
      : super(key: key);
  final dynamic user;
  final String role;
  final String id;

  @override
  State<SingleAdmin> createState() => _SingleAdminState();
}

class _SingleAdminState extends State<SingleAdmin> {
  // bool suspend = false;
  String? id;
  bool isSwitch = false;
  final dio = Dio();
  int? index;

  Widget personal(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 20),
          ),
          const Divider(
            thickness: 2.0,
          )
        ],
      ),
    );
  }

  void switchIt() async {
    setState(() => isSwitch = true);
    Response response = await dio.patch(LiveApis.suspendAdmin + id!,
        data: {"suspend": !widget.user['suspend']});
    if (response.statusCode == 200) {
      setState(() {
        isSwitch = false;
        widget.user['suspend'] = !widget.user['suspend'];
        widget.user['suspend'] ? index = 0 : index = 1;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Admins(
                    role: widget.role,
                    id: widget.id,
                  )));
    } else {
      setState(() => isSwitch = false);
    }
  }

  @override
  void initState() {
    super.initState();
    id = widget.user['_id'];
    index = widget.user['suspend'] ? 0 : 1;
  }

  @override
  Widget build(BuildContext context) {
    final details = [
      '${widget.user['firstName']} ${widget.user['lastName']}',
      widget.user['gender'],
      widget.user['city'],
      widget.user['country'],
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user['firstName']} ${widget.user['lastName']}'),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .4,
            child: Image.network(
              widget.user['profile'],
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...details.map((e) => personal(e)).toList()
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user['email'],
                          style: const TextStyle(fontSize: 20),
                        ),
                        const Divider(
                          thickness: 2.0,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Suspend',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  toggleSwitch(switchIt, index!)
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
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
