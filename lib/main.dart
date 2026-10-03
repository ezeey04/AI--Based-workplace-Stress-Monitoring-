import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/login.dart';

void main() {
  runApp(myapp());
}

class myapp extends StatelessWidget {
  const myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ippage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ippage extends StatefulWidget {
  const ippage({super.key});

  @override
  State<ippage> createState() => _ippageState();
}

class _ippageState extends State<ippage> {

  TextEditingController ipcontroller =
  new TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Color(0xFFFAF7FC),

      appBar: AppBar(
        title: Text(
          'Server Connection',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF6538BD),
        elevation: 0,
      ),

      body: SingleChildScrollView(

        child: Padding(
          padding: EdgeInsets.all(25),

          child: Column(

            children: [

              SizedBox(height: 50),

              // ICON
              Container(
                width: 100,
                height: 100,

                decoration: BoxDecoration(
                  color: Color(0xFF6538BD),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(76, 42, 145, 0.28),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),

                child: Icon(
                  Icons.dns,
                  color: Colors.white,
                  size: 50,
                ),
              ),

              SizedBox(height: 30),

              // TITLE
              Text(
                'Connect to Server',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4D2B91),
                ),
              ),

              SizedBox(height: 10),

              // DESCRIPTION
              Text(
                'Enter the IP address of your server\nto connect to the application.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF76698D),
                  height: 1.5,
                ),
              ),

              SizedBox(height: 40),

              // CARD
              Container(
                padding: EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(76, 42, 145, 0.12),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      'IP Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF352746),
                      ),
                    ),

                    SizedBox(height: 10),

                    TextFormField(
                      controller: ipcontroller,

                      keyboardType:
                      TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      decoration: InputDecoration(

                        hintText: 'Example: 192.168.1.10',

                        prefixIcon: Icon(
                          Icons.computer,
                          color: Color(0xFF7040C9),
                        ),

                        filled: true,

                        fillColor: Color(0xFFF1E9FF),

                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFF7040C9),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 25),

                    // CONNECT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(

                        onPressed: () {
                          senddata();
                        },

                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor: Color(0xFF6538BD),

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),

                          elevation: 3,
                        ),

                        child: Row(

                          mainAxisAlignment:
                          MainAxisAlignment.center,

                          children: [

                            Icon(
                              Icons.login,
                              color: Colors.white,
                            ),

                            SizedBox(width: 10),

                            Text(
                              'CONNECT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // BOTTOM INFO
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Color(0xFF9A8FB0),
                  ),

                  SizedBox(width: 8),

                  Text(
                    'Make sure the server is running',
                    style: TextStyle(
                      color: Color(0xFF76698D),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void senddata() async {

    SharedPreferences sh =
    await SharedPreferences.getInstance();

    sh.setString(
      'url',
      'http://${ipcontroller.text}:8000/myapp',
    );

    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (context) => loginpage(),
      ),
    );
  }
}