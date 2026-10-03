import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class viewwork extends StatefulWidget {
  const viewwork({super.key});

  @override
  State<viewwork> createState() => _viewworkState();
}


class _viewworkState extends State<viewwork> {

  List<Map<String, dynamic>> works = [];


  @override
  void initState() {
    super.initState();
    getdata();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text('View Work'),
        backgroundColor: Colors.blueAccent,
        leading: Icon(Icons.work),
      ),

      body: Container(

        padding: EdgeInsets.all(30),

        child: SingleChildScrollView(

          child: Column(

            children: works.map((i) {

              return Card(

                elevation: 5,

                child: Container(

                  width: double.infinity,

                  padding: EdgeInsets.all(15),

                  child: Column(

                    children: [

                      Text(
                        i['worktitle'].toString(),

                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        i['work_description'].toString(),
                      ),

                      SizedBox(height: 10),

                      Text(
                        'Date: ${i['date']}',
                      ),

                      SizedBox(height: 10),

                      Text(
                        'Status: ${i['status']}',
                      ),

                      SizedBox(height: 15),

                      if (i['status']
                          .toString()
                          .trim()
                          .toLowerCase() ==
                          'completed')

                        Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        )

                      else

                        ElevatedButton(

                          onPressed: () async {

                            print(
                              'ASSIGN SUB ID = ${i['id']}',
                            );


                            await Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (context) =>
                                    updatestatus(
                                      id: i['id'].toString(),
                                    ),

                              ),

                            );


                            getdata();

                          },

                          child: Text(
                            'Update Status',
                          ),

                        ),

                    ],

                  ),

                ),

              );

            }).toList(),

          ),

        ),

      ),

    );

  }


  Future<void> getdata() async {

    SharedPreferences sh =
    await SharedPreferences.getInstance();

    String url =
        sh.getString('url') ?? '';

    String lid =
        sh.getString('lid') ?? '';


    final urls =
    Uri.parse(
      '$url/mobileviewwork/',
    );


    final response =
    await http.post(

      urls,

      body: {
        'lid': lid,
      },

    );


    print(
      'WORK RESPONSE = ${response.body}',
    );


    if (response.statusCode == 200) {

      var jsondata =
      jsonDecode(response.body);


      if (jsondata['status'] == 'ok') {

        List<Map<String, dynamic>> temp = [];


        for (var i in jsondata['data']) {

          temp.add({

            'id':
            i['id'].toString(),

            'date':
            i['date'].toString(),

            'status':
            i['status'].toString(),

            'worktitle':
            i['worktitle'].toString(),

            'work_description':
            i['work_description'].toString(),

          });

        }


        setState(() {

          works = temp;

        });

      }

    }

  }

}



class updatestatus extends StatefulWidget {

  final String id;


  const updatestatus({

    super.key,

    required this.id,

  });


  @override
  State<updatestatus> createState() =>
      _updatestatusState();

}



class _updatestatusState
    extends State<updatestatus> {

  String status = 'pending';


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(
          'Update Status',
        ),

        backgroundColor:
        Colors.blueAccent,

        leading: Icon(
          Icons.update,
        ),

      ),

      body: Container(

        padding:
        EdgeInsets.all(30),

        child: Column(

          children: [

            DropdownButtonFormField<String>(

              value: status,

              decoration: InputDecoration(

                labelText:
                'Select Status',

                border:
                OutlineInputBorder(),

              ),

              items: [

                DropdownMenuItem(

                  value: 'pending',

                  child:
                  Text('Pending'),

                ),

                DropdownMenuItem(

                  value: 'working',

                  child:
                  Text('Working'),

                ),

                DropdownMenuItem(

                  value: 'completed',

                  child:
                  Text('Completed'),

                ),

              ],

              onChanged: (value) {

                setState(() {

                  status =
                  value!;

                });

              },

            ),

            SizedBox(
              height: 30,
            ),

            ElevatedButton(

              onPressed: () {

                updatedata();

              },

              child: Text(
                'Update Status',
              ),

            ),

          ],

        ),

      ),

    );

  }


  Future<void> updatedata() async {

    if (widget.id.isEmpty) {

      Fluttertoast.showToast(
        msg: 'ID is missing',
      );

      return;

    }


    SharedPreferences sh =
    await SharedPreferences.getInstance();


    String url =
        sh.getString('url') ?? '';


    final urls =
    Uri.parse(
      '$url/mobileupdatestatus/',
    );


    final response =
    await http.post(

      urls,

      body: {

        'id':
        widget.id,

        'status':
        status,

      },

    );


    print(
      'RESPONSE = ${response.body}',
    );


    if (response.statusCode == 200) {

      var jsondata =
      jsonDecode(response.body);


      if (jsondata['status'] == 'ok') {

        Fluttertoast.showToast(
          msg:
          'Status updated successfully',
        );


        Navigator.pop(
          context,
        );

      }

    }

  }

}