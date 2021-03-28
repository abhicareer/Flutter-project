import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fproject/Auth/login/fabeanimation.dart';
import 'package:fproject/todo/components/models.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_response.dart';

GlobalKey<_CompletedState> completeKey = GlobalKey();

// ignore: must_be_immutable
class Completed extends StatefulWidget {
  Function selectedIndex;
  Function moveIndex;
  int moveToIndex = 0;
  Function updateAllData;
  Function updateDeleteAndData;
  Function edit;
  String searchData;
  int completedCount;
  bool search;
  bool filter;
  bool loading;
  List<Item> data = [];
  Completed(
      {Key key,
      this.data,
      this.filter,
      this.search,
      this.selectedIndex,
      this.searchData,
      this.edit,
      this.loading,
      this.moveIndex,
      this.moveToIndex,
      this.completedCount,
      this.updateAllData,
      this.updateDeleteAndData})
      : super(key: key);
  @override
  _CompletedState createState() => _CompletedState();
}

class _CompletedState extends State<Completed> {
  Item moreOption;
  bool showPagination = false;
  int _currentMax = 15;
  bool reachLast = false;
  bool showSnackBar = false;
  List<Item> data;
  ScrollController _scrollController = ScrollController();

  void _updateLoading() {
    setState(() {
      this.widget.loading = !widget.loading;
    });
  }

  _showModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 170,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Center(
                child: GridView.count(
                  crossAxisCount: 3,
                  children: [
                    IconButton(
                        icon: Icon(
                          FontAwesomeIcons.spinner,
                          color: Colors.white,
                          size: 80,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _handleMarkedCompleted(moreOption);
                        }),
                    IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 80,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _handleEdit(moreOption);
                        }),
                    IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 80,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _handleDelete(moreOption);
                        }),
                  ],
                ),
              ),
            ),
            decoration: BoxDecoration(
                color: Colors.teal[200],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
          );
        });
  }

  void _handleEdit(item) {
    widget.edit(item);
    widget.selectedIndex(1, 2);
  }

  _showModalBottomSheet1(BuildContext context, item) {
    setState(() {
      this.moreOption = item;
    });
    _showModalBottomSheet(context);
  }

  _handleDelete(moreOption) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("Delete To Do"),
            content: Text("Are you sure?"),
            actions: [
              CupertinoDialogAction(
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: Text('Yes'),
                onPressed: () async {
                  _updateLoading();
                  Navigator.pop(context);
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String token = prefs.getString("token");
                  deleteTodo(moreOption.id, token).then((_) {
                    widget.updateDeleteAndData(moreOption);
                    _updateLoading();
                  });
                },
              ),
            ],
          );
        });
  }

  _handleMarkedCompleted(item) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("Mark as Pending"),
            content: Text("Are you sure?"),
            actions: [
              CupertinoDialogAction(
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: Text('Yes'),
                onPressed: () async {
                  _updateLoading();
                  Navigator.pop(context);
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String token = prefs.getString("token");
                  markedInCompletedTodo(moreOption.id, token).then((value) {
                    widget.updateAllData(value);
                    _updateLoading();
                    widget.moveIndex(0);
                  });
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (_currentMax < widget.data.length) {
      this.setState(() {
        data = widget.data.sublist(0, _currentMax);
      });
    } else {
      this.setState(() {
        data = widget.data;
        _currentMax = widget.data.length;
      });
    }
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
        print('list');
      }
    });
  }

  _getMoreData() {
    if (_currentMax + 10 > widget.data.length &&
        _currentMax < widget.data.length) {
      this.setState(() {
        reachLast = true;
      });
      Timer(
          Duration(seconds: 2),
          () => this.setState(() {
                data = widget.data.sublist(0, widget.data.length);
                _currentMax = widget.data.length;
                reachLast = false;
              }));
    } else if (_currentMax == widget.data.length) {
      this.setState(() {
        showSnackBar = true;
      });
      Timer(
          Duration(seconds: 2),
          () => this.setState(() {
                showSnackBar = false;
              }));
    } else {
      this.setState(() {
        reachLast = true;
      });
      Timer(
          Duration(seconds: 2),
          () => this.setState(() {
                data = widget.data.sublist(0, _currentMax + 10);
                _currentMax = _currentMax + 10;
                reachLast = false;
              }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.data.length > 0
          ? !widget.search
              ? !widget.filter
                  ? Container(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: Column(children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Container(
                              child: Column(
                                children: [
                                  _buildPanel(),
                                  reachLast
                                      ? Center(
                                          child: Padding(
                                          padding: const EdgeInsets.all(25.0),
                                          child: CupertinoActivityIndicator(),
                                        ))
                                      : Container(),
                                  showSnackBar
                                      ? Container(
                                          color: Colors.teal,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 50,
                                          child: Center(
                                            child: Text(
                                              'No More Data ...',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                              padding: const EdgeInsets.only(
                                  bottom: kFloatingActionButtonMargin + 48),
                            ),
                          ),
                        )
                      ]))
                  : Container(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: Column(children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              child: Column(
                                children: [
                                  _buildPanel(),
                                ],
                              ),
                            ),
                          ),
                        )
                      ]))
              : Container(
                  padding: EdgeInsets.only(bottom: 15.0),
                  child: Column(children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          child: Column(
                            children: [
                              _buildPanel(),
                            ],
                          ),
                        ),
                      ),
                    )
                  ]))
          : Center(
              child: Text('No Todo'),
            ),
    );
  }

  Widget _buildPanel() {
    return !widget.loading
        ? !widget.search
            ? !widget.filter
                ? ExpansionPanelList(
                    dividerColor: Colors.teal,
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        data[index].isExpanded = !isExpanded;
                      });
                    },
                    children: data.map<ExpansionPanel>((Item item) {
                      return ExpansionPanel(
                        canTapOnHeader: true,
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            dense: !isExpanded,
                            title: Text(
                              item.title,
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.more_horiz),
                              tooltip: 'More',
                              onPressed: () {
                                _showModalBottomSheet1(context, item);
                              },
                            ),
                          );
                        },
                        body: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0),
                              child: Divider(
                                color: Colors.grey,
                                height: 1.0,
                              ),
                            ),
                            ListTile(
                                title: Text(item.description),
                                subtitle: Text('Create on ' +
                                    DateFormat('dd/MM/yyyy').format(
                                        DateTime.parse(item.timestamp)))),
                            // subtitle: Text(
                            //     'To delete this panel, tap the trash can icon'),
                            // trailing: Icon(Icons.delete),
                            // onTap: () {
                            //   print('object');
                            // }),
                            SingleChildScrollView(
                                padding:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                    children:
                                        item.todochip.map((Todochip chip) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 3.0),
                                    child: Chip(
                                      avatar: CircleAvatar(
                                        backgroundColor: Colors.grey.shade800,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.teal,
                                        ),
                                      ),
                                      label: Text(chip.chips),
                                    ),
                                  );
                                }).toList()))
                          ],
                        ),
                        isExpanded: item.isExpanded,
                      );
                    }).toList())
                : ExpansionPanelList(
                    dividerColor: Colors.teal,
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        widget.data[index].isExpanded = !isExpanded;
                      });
                    },
                    children: widget.data.map<ExpansionPanel>((
                      Item item,
                    ) {
                      return ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            dense: !isExpanded,
                            title: Text(
                              item.title,
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.more_horiz),
                              tooltip: 'More',
                              onPressed: () {
                                _showModalBottomSheet1(context, item);
                              },
                            ),
                          );
                        },
                        body: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0),
                              child: Divider(
                                color: Colors.grey,
                                height: 1.0,
                              ),
                            ),
                            ListTile(
                              title: Text(item.description),
                              subtitle: Text('Create on ' +
                                  DateFormat('dd/MM/yyyy')
                                      .format(DateTime.parse(item.timestamp))),
                            ),
                            SingleChildScrollView(
                                padding:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                    children:
                                        item.todochip.map((Todochip chip) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 3.0),
                                    child: Chip(
                                      avatar: CircleAvatar(
                                        backgroundColor: Colors.grey.shade800,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.teal,
                                        ),
                                      ),
                                      label: Text(chip.chips),
                                    ),
                                  );
                                }).toList()))
                          ],
                        ),
                        isExpanded: item.isExpanded,
                      );
                    }).toList())
            : widget.searchData.length > 0
                ? ExpansionPanelList(
                    dividerColor: Colors.teal,
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        widget.data[index].isExpanded = !isExpanded;
                      });
                    },
                    children: widget.data.map<ExpansionPanel>((
                      Item item,
                    ) {
                      return ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            dense: !isExpanded,
                            title: Text(
                              item.title,
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.more_horiz),
                              tooltip: 'More',
                              onPressed: () {
                                _showModalBottomSheet1(context, item);
                              },
                            ),
                          );
                        },
                        body: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0),
                              child: Divider(
                                color: Colors.grey,
                                height: 1.0,
                              ),
                            ),
                            ListTile(
                              title: Text(item.description),
                              subtitle: Text('Create on ' +
                                  DateFormat('dd/MM/yyyy')
                                      .format(DateTime.parse(item.timestamp))),
                            ),
                            SingleChildScrollView(
                                padding:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                    children:
                                        item.todochip.map((Todochip chip) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 3.0),
                                    child: Chip(
                                      avatar: CircleAvatar(
                                        backgroundColor: Colors.grey.shade800,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.teal,
                                        ),
                                      ),
                                      label: Text(chip.chips),
                                    ),
                                  );
                                }).toList()))
                          ],
                        ),
                        isExpanded: item.isExpanded,
                      );
                    }).toList())
                : Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text('search ...'),
                  )
        : Container(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: SpinKitFoldingCube(color: Colors.teal),
            ),
          );
  }
}
