import 'package:flutter/material.dart';

class Suspend extends StatelessWidget {
  const Suspend({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .4,
              child: Image.asset('images/sad.png'),
            ),
            const Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Your Account has been Suspended. Contact Super Admin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 30, color: Colors.red,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
