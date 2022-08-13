import 'package:flutter/material.dart';


class SingleUser extends StatefulWidget {
  const SingleUser({Key? key, required this.user}) : super(key: key);
  final dynamic user;

  @override
  State<SingleUser> createState() => _SingleUserState();
}

class _SingleUserState extends State<SingleUser> {
  Widget personal(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(
              fontSize: 20
          ),),
          const Divider(thickness: 2.0,)
        ],
      ),
    );
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
          const SizedBox(
            child: CircleAvatar(
              radius: 100,
              child: Icon(Icons.person),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personal', style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),),
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
                  const Text('Contact', style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.user['email'], style: const TextStyle(
                            fontSize: 20
                        ),),
                        const Divider(thickness: 2.0,)
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
