import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'api_response.dart';

// ignore: must_be_immutable
class AddDiary extends StatefulWidget {
  String token;
  Function addData;
  AddDiary({Key key, this.token, this.addData}) : super(key: key);

  @override
  _AddDiaryState createState() => _AddDiaryState();
}

class _AddDiaryState extends State<AddDiary> {
  TextEditingController noteTitle = new TextEditingController();
  TextEditingController noteContent = new TextEditingController();

  List<String> chips = [];
  bool loading = false;

  loadingChange() {
    setState(() {
      this.loading = !loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text('Add'),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.grey[200],
            height: MediaQuery.of(context).size.height,
            //color: Colors.white,
            child: new Theme(
              data: new ThemeData(
                primaryColor: Colors.black,
                primaryColorDark: Colors.black,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20.0,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 40.0,
                          width: 40.0,
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10),
                                bottom: Radius.circular(10)),
                          ),
                          child: Icon(
                            FontAwesomeIcons.bookOpen,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextField(
                        controller: noteTitle,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        style: TextStyle(color: Colors.black),
                        decoration: new InputDecoration(
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.black)),
                          hintText: 'Diary Title',
                          labelText: 'Title',
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextField(
                        controller: noteContent,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.multiline,
                        maxLines: 4,
                        style: TextStyle(color: Colors.black),
                        decoration: new InputDecoration(
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.black)),
                          hintText: 'Diary Content',
                          labelText: 'Content',
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      RaisedButton.icon(
                        icon: Icon(Icons.add, color: Colors.white),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        color: Colors.teal,
                        onPressed: !loading
                            ? () => addDiarys(
                                context,
                                widget.token,
                                noteContent.text,
                                noteTitle.text,
                                widget.addData,
                                loadingChange)
                            : null,
                        label: !loading
                            ? Text(
                                'Create',
                                style: TextStyle(color: Colors.white),
                              )
                            : CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.teal)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
