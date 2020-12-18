// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@JS()
// ignore: library_names
library alertMessage;

import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myweb/adaptive.dart';
import 'package:myweb/demo_localizations.dart';
import 'package:js/js.dart';
import 'package:myweb/main.dart';
import 'package:http_parser/http_parser.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

@JS('alertMessage')
external void alertMessage(String obj);

const appBarDesktopHeight = 128.0;

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

var _emailController = TextEditingController();
var _countryController = TextEditingController();
//var _textController = TextEditingController();
var _nameController = TextEditingController();

class _HomePageState extends State<HomePage> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  var _displayBanner = false;
  var _showMultipleActions = true;
  var _showLeading = true;
  var selectedFileName = "None";
  // ignore: non_constant_identifier_names
  //Country _selected_c;
  Uint8List uploadfile;
  // ignore: non_constant_identifier_names
  _JourneyDataSource _JourneysDataSource;
  @override
  void initState() {
    _showLeading = false;
    getLeaderboardList();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _JourneysDataSource ??= _JourneyDataSource(context);
  }

  void getLeaderboardList() async {
    var response = await http.get(ApiUrl + '/api/v1/ranking_list');
    print(response.body);
    print(response.statusCode);
    var listofobjects = json.decode(response.body);
    // print(listofobjects[0]);
    // print(listofobjects[0]['id']);
    // print(listofobjects[0]['username']);
    // print(listofobjects[0]['objective_value']);
    // print(listofobjects.length);
    //_JourneysDataSource._Journeys.clear();
    DateFormat dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss.SZ");
    DateTime now = DateTime.now();
    List<_Journey> tempJourney = [];
    for (int i = 0; i < listofobjects.length; i++) {
      DateTime dateTime = dateFormat.parse(listofobjects[i]['created_at']);
      dateTime = dateTime.toLocal();

      String time = dateTime.hour.toString() +
          ":" +
          dateTime.minute.toString() +
          ":" +
          dateTime.second.toString();
      var objval;
      if (listofobjects[i]['objective_value'] < 0) {
        objval = 0;
      } else {
        objval = listofobjects[i]['objective_value'];
      }
      var newJourney = _Journey(
          listofobjects[i]['id'],
          listofobjects[i]['username'],
          listofobjects[i]['country'],
          objval,
          time);
      //_JourneysDataSource._Journeys.add(newJourney);
      tempJourney.add(newJourney);
      //_JourneysDataSource._Journeys.add(newJourney);
    }

    setState(() {
      _JourneysDataSource._Journeys = tempJourney;
    });
    //print(_JourneyDataSource.);
    _JourneysDataSource._selectAll(false);
    didChangeDependencies();
    setState(() {});
  }

  void _sort<T>(
    Comparable<T> Function(_Journey d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _JourneysDataSource._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  String filename() {
    if (selectedFileName == "None") {
      return "Make new Submission";
    } else {
      return selectedFileName;
    }
  }

  void initUpload() async {
    Navigator.pop(context);
    String name = _nameController.text;
    String pvtToken = "123123";
    String probId = "1";
    String email = _emailController.text;
    String country = _countryController.text;
    var url = Uri.parse(ApiUrl +
        "/api/v1/problems/" +
        probId +
        "/solutions/upload?private_token=" +
        pvtToken);
    var request = new http.MultipartRequest("POST", url);

    request.files.add(http.MultipartFile.fromBytes('file', uploadfile,
        contentType: new MediaType('application', 'octet-stream'),
        filename: "text_upload.txt"));
    request.fields["name"] = "photcat";
    request.fields["email"] = email;
    request.fields["country"] = country;
    request.fields["username"] = name;

    request.send().then((response) async {
      var res = await response.stream.bytesToString();
      Map valueMap = json.decode(res);
      print(valueMap);
      print(response.statusCode);

      // var current = double.parse(valueMap["current"]);
      // var best = double.parse(valueMap["best"]);
      var current = valueMap["current"];
      var best = valueMap["best"];
      // ignore: non_constant_identifier_names
      var double_val = valueMap["double_item"];
      // ignore: non_constant_identifier_names
      bool error_in_inp = false;
      AlertType alt = AlertType.success;
      // ignore: non_constant_identifier_names
      String Alertmessage =
          "Score: " + current.toString() + "Your submission was succesful";

      if (double_val) {
        Alertmessage = "Item(s) is used double time";
        error_in_inp = true;
        alt = AlertType.info;
      }

      if (current < 0) {
        Alertmessage = "The total weight exceeds the max weight";
        error_in_inp = true;
        alt = AlertType.info;
      }

      if (current == best && !error_in_inp) {
        Alertmessage = "Score: " +
            current.toString() +
            "Your current score is the same as your best score";
      }
      if (current > best && !error_in_inp) {
        Alertmessage = "Score: " +
            current.toString() +
            "Your score has improved, Good work!";
      }
      if (current < best && !error_in_inp) {
        Alertmessage = "Score: " +
            current.toString() +
            "Your score is less than your best and the best score was retained";
      }
      if (response.statusCode == 201) {
        setState(() {
          selectedFileName = "Uploaded";
        });
        getLeaderboardList();
        print("Uploaded!");
        Alert(
          context: context,
          type: alt,
          title: "Submitted",
          desc: Alertmessage,
          buttons: [
            DialogButton(
              child: Text(
                "Done",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              width: 120,
            )
          ],
        ).show();
      } else {
        getLeaderboardList();
        Alert(
          context: context,
          type: AlertType.error,
          title: "Submission Failed",
          desc: "",
          buttons: [
            DialogButton(
              child: Text(
                "Done",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              width: 120,
            )
          ],
        ).show();
      }
    });
    setState(() {
      selectedFileName = "None";
      _displayBanner = false;
    });
  }

  _startFilePicker() async {
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      // read file content as dataURL
      final files = uploadInput.files;
      if (files.length == 1) {
        final file = files[0];
        FileReader reader = FileReader();

        reader.onLoadEnd.listen((e) {
          setState(() {
            uploadfile = reader.result;
            selectedFileName = "File selected";
          });
        });

        reader.onError.listen((fileEvent) {
          setState(() {
            selectedFileName = "Some Error occured while reading the file";
          });
        });

        reader.readAsArrayBuffer(file);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = isDisplayDesktop(context);

    //     var _emailController = TextEditingController();
    // var _countryController = TextEditingController();
    // //var _textController = TextEditingController();
    // var _nameController = TextEditingController();
    //var _textController = TextEditingController();

    final banner = MaterialBanner(
        content: Text(filename()),
        leading: _showLeading
            ? CircleAvatar(
                child: Icon(Icons.upload_file, color: colorScheme.onPrimary),
                backgroundColor: colorScheme.primary,
              )
            : null,
        actions: [
          FlatButton(
            child: Text("Select"),
            onPressed: () {
              _startFilePicker();
            },
          ),
          FlatButton(
            child: Text("Upload"),
            onPressed: () {
              setState(() {
                selectedFileName = "Uploading ...";
              });
              //initUpload();
              //showSubAlert();
              Alert(
                  context: context,
                  title: "New Submission",
                  content: Column(
                    children: <Widget>[
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.account_circle),
                          labelText: 'Preferred name',
                        ),
                      ),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.email),
                          labelText: 'Email address',
                        ),
                      ),
                      TextField(
                        controller: _countryController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.location_on),
                          labelText: 'Country',
                        ),
                      ),
                    ],
                  ),
                  buttons: [
                    DialogButton(
                      onPressed: () => initUpload(),
                      child: Text(
                        "Submit",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    )
                  ]).show();
            },
          ),
        ],
        backgroundColor: Colors.white);

    final body = Scrollbar(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _displayBanner ? banner : SizedBox.shrink(),
          PaginatedDataTable(
            header: new DropdownButton<String>(
              items: <String>['Instance 1', 'Instance 2'].map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              onChanged: (_) {
                print("changed");
              },
            ),
            showCheckboxColumn: false,
            rowsPerPage: _rowsPerPage,
            onRowsPerPageChanged: (value) {
              setState(() {
                _rowsPerPage = value;
              });
            },
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            onSelectAll: _JourneysDataSource._selectAll,
            columns: [
              DataColumn(
                label: Text("Position"),
                onSort: (columnIndex, ascending) =>
                    _sort<String>((d) => d.name, columnIndex, ascending),
              ),
              DataColumn(
                label: Text("Name"),
                onSort: (columnIndex, ascending) =>
                    _sort<String>((d) => d.name, columnIndex, ascending),
              ),
              DataColumn(
                label: Text("Country"),
                numeric: true,
                onSort: (columnIndex, ascending) =>
                    _sort<num>((d) => d.obj_val, columnIndex, ascending),
              ),
              DataColumn(
                label: Text("Objective Value"),
                numeric: true,
                onSort: (columnIndex, ascending) =>
                    _sort<num>((d) => d.obj_val, columnIndex, ascending),
              ),
              DataColumn(
                label: Text("Last submission"),
                numeric: true,
                onSort: (columnIndex, ascending) =>
                    _sort<num>((d) => d.obj_val, columnIndex, ascending),
              ),
            ],
            source: _JourneysDataSource,
          ),
        ],
      ),
    );

    if (isDesktop) {
      return Row(
        children: [
          ListDrawer(),
          const VerticalDivider(width: 1),
          Expanded(
            child: Scaffold(
              appBar: AdaptiveAppBar(
                isDesktop: true,
                callback: (value) {
                  if (value == "favorite") {
                    setState(() {
                      _displayBanner = !_displayBanner;
                    });
                  }
                },
              ),
              body: body,
              floatingActionButton: FloatingActionButton.extended(
                heroTag: 'Extended Add',
                onPressed: () {},
                label: Text(
                  DemoLocalizations.of(context).starterAppGenericButton,
                  style: TextStyle(color: colorScheme.onSecondary),
                ),
                icon: Icon(Icons.add, color: colorScheme.onSecondary),
                tooltip: DemoLocalizations.of(context).starterAppTooltipAdd,
              ),
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: const AdaptiveAppBar(),
        body: body,
        drawer: ListDrawer(),
        floatingActionButton: FloatingActionButton(
          heroTag: 'Add',
          onPressed: () {},
          tooltip: DemoLocalizations.of(context).starterAppTooltipAdd,
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      );
    }
  }
}

class _Journey {
  _Journey(this.index, this.name, this.country, this.obj_val, this.last_sub);
  final int index;
  final String name;
  final String country;
  // ignore: non_constant_identifier_names
  final double obj_val;
  // ignore: non_constant_identifier_names
  final String last_sub;
  bool selected = false;
}

class _JourneyDataSource extends DataTableSource {
  _JourneyDataSource(this.context) {
    //final localizations = Gallery of(context);
    _Journeys = <_Journey>[
      _Journey(1, "Loading Data..", "Loading Data..", 0, "Loading Data.."),
      //_Journey(2, "Test", "Australia", 237, "5 mins agao"),
    ];
  }

  final BuildContext context;
  // ignore: non_constant_identifier_names
  List<_Journey> _Journeys;

  void _sort<T>(Comparable<T> Function(_Journey d) getField, bool ascending) {
    _Journeys.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _Journeys.length) return null;
    // ignore: non_constant_identifier_names
    final Journey = _Journeys[index];
    return DataRow.byIndex(
      index: index,
      selected: Journey.selected,
      onSelectChanged: (value) {
        if (Journey.selected != value) {
          _selectedCount += value ? 1 : -1;
          assert(_selectedCount >= 0);
          Journey.selected = value;
          notifyListeners();
        }
      },
      cells: [
        DataCell(Text('${Journey.index}')),
        DataCell(Text(Journey.name)),
        DataCell(Text(Journey.country)),
        DataCell(Text('${Journey.obj_val}')),
        DataCell(Text(Journey.last_sub)),
      ],
    );
  }

  @override
  int get rowCount => _Journeys.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  void _selectAll(bool checked) {
    for (final Journey in _Journeys) {
      Journey.selected = checked;
    }
    _selectedCount = checked ? _Journeys.length : 0;
    notifyListeners();
  }
}

typedef BarCallback<T> = void Function(T value);

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdaptiveAppBar({
    Key key,
    this.callback,
    this.isDesktop = false,
  }) : super(key: key);

  final BarCallback<String> callback;
  final bool isDesktop;

  @override
  Size get preferredSize => isDesktop
      ? const Size.fromHeight(appBarDesktopHeight)
      : const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return AppBar(
      automaticallyImplyLeading: !isDesktop,
      title: isDesktop
          ? null
          : Text(DemoLocalizations.of(context).starterAppGenericTitle),
      bottom: isDesktop
          ? PreferredSize(
              preferredSize: const Size.fromHeight(26),
              child: Container(
                alignment: AlignmentDirectional.centerStart,
                margin: const EdgeInsetsDirectional.fromSTEB(72, 0, 0, 22),
                child: Text(
                  DemoLocalizations.of(context).starterAppGenericTitle,
                  style: themeData.textTheme.headline6.copyWith(
                    color: themeData.colorScheme.onPrimary,
                  ),
                ),
              ),
            )
          : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: DemoLocalizations.of(context).starterAppTooltipShare,
          onPressed: () {
            this.callback("share");
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite),
          tooltip: DemoLocalizations.of(context).starterAppTooltipFavorite,
          onPressed: () {
            this.callback("favorite");
          },
        ),
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: DemoLocalizations.of(context).starterAppTooltipSearch,
          onPressed: () {
            this.callback("search");
          },
        ),
      ],
    );
  }
}

class ListDrawer extends StatefulWidget {
  @override
  _ListDrawerState createState() => _ListDrawerState();
}

class _ListDrawerState extends State<ListDrawer> {
  static final numItems = 9;

  int selectedItem = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    DivElement div = new DivElement();
    div.text = "Here's my new DivElem";
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            ListTile(
              title: Text(
                DemoLocalizations.of(context).starterAppTitle,
                style: textTheme.headline6,
              ),
              subtitle: Text(
                DemoLocalizations.of(context).starterAppGenericSubtitle,
                style: textTheme.bodyText2,
              ),
            ),
            const Divider(),
            ...Iterable<int>.generate(numItems).toList().map((i) {
              return ListTile(
                enabled: true,
                selected: i == selectedItem,
                leading: const Icon(Icons.favorite),
                title: Text(
                  DemoLocalizations.of(context).starterAppDrawerItem(i + 1),
                ),
                onTap: () {
                  setState(() {
                    //alertMessage('Flutter is calling upon JavaScript!');
                    selectedItem = i;
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
