import 'dart:convert';
import 'dart:io';
import "package:flutter/material.dart";
import 'package:path_provider/path_provider.dart';

void main () {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _toDoList = [];
  final _toDoController = TextEditingController();
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;


  @override
  void initState() {
    super.initState();

    _readData().then((data){
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addToDo() {
   setState(() {
     Map<String, dynamic> newToDo = Map();
     newToDo["title"] = _toDoController.text;
     _toDoController.text = "";
     newToDo["ok"] = false;
     _toDoList.add(newToDo);
     _saveData();
   });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Lista de Tarefas",
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold
            ),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _toDoController,
                  decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 20.0,
                      )
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 22.0
                  ),
                ),
              ),
              RaisedButton(
                color: Colors.red,
                child: Text("ADD",
                  style: TextStyle(fontSize: 17.0),
                ),
                textColor: Colors.white,
                onPressed: _addToDo,
              )
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
              child: ListView.builder(
                padding: EdgeInsets.only(
                    top: 10.0
                ),
                itemCount: _toDoList.length,
                itemBuilder: buildItem,
              ),
              onRefresh: refreshList,
          )
        ),
      ]),
    );
  }

  Future<Null> refreshList() async{
    await Future.delayed(
      Duration(seconds: 1),
    );

    setState(() {
      _toDoList.sort((a, b){
        if(a["ok"] && !b["ok"]) return 1;
        else if(!a["ok"] && b["ok"]) return -1;
        else return 0;
      });

      _saveData();
    });

    return null;
  }

  Widget buildItem(context, index){

    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"],
        style: TextStyle(
          fontSize: 20.0,
          color: Colors.deepPurple
        ),
        ),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(
            _toDoList[index]["ok"] ? Icons.check : Icons.error,
          ),
        ),
        onChanged: (c){
          setState(() {
            _toDoList[index]["ok"] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction){
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _toDoList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                }
            ),
            duration: Duration(seconds: 2),
          );

          Scaffold.of(context).showSnackBar(snack);

        });
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData () async {
    String data = json.encode(_toDoList);
    final file = await _getFile();

    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}

