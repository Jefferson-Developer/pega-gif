import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:gif_app2/git_page.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;
  List pesquisas = [];
  TextEditingController controller = TextEditingController();

  Future<Map> _getGifs() async {
    http.Response response;
    if (_search == null) {
      response =
          await http.get("https://api.giphy.com/v1/gifs/trending?api_key=n"
              "POTPG7zSK829O3b6hDiR7qdtw15C9Hu&limit=20&rating=g");
    } else {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=nPOTPG7zSK829O3b6hDiR7qdtw15C9Hu&q"
          "=$_search&limit=19&offset=$_offset&rating=g&lang=en");
    }
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    try {
      _getData().then((data) {
        setState(() {
          pesquisas = json.decode(data);
        });
      });
    } catch (c) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:  Container(
          width: 250,
          color: Colors.red,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 30),
                child:Text(
                  "Ultimas Pesquisas", style: TextStyle(
                    color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold
                ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: pesquisas.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        trailing:
                        IconButton(
                          onPressed: (){
                            setState(() {
                              pesquisas.removeAt(index);
                              _saveData();
                            });
                          },
                          icon: Icon(
                            Icons.delete, color: Colors.white,
                          ),
                        ),
                        onLongPress: (){
                          setState(() {
                            pesquisas.removeAt(index);
                            _saveData();
                          });
                        },
                        onTap: (){
                          setState(() {
                            _search = pesquisas[index];
                            Navigator.pop(context);
                            _saveData();
                            controller.text = pesquisas[index];
                          });
                        },
                        title: Text(pesquisas[index], style: TextStyle(
                          fontSize: 20, color: Colors.white
                        ),),
                      );
                    }),
              ),
            ],
          )
        ),

      appBar: AppBar(
        title: Text("Pega Gifs"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                        labelText: "Procure um Gif",
                        labelStyle: TextStyle(color: Colors.red, fontSize: 18)),
                  ),
                ),
                RaisedButton(
                  onPressed: (){
                    setState(() {
                      _search = controller.text;
                      pesquisas.add(controller.text);
                      _saveData();
                    });
                  },
                  child: Text(
                    "Pesquisar", style: TextStyle(
                    color: Colors.white
                  ),
                  ),
                  color: Colors.red,
                ),
              ],
            )
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(), // map
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      height: 200,
                      width: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return _createGitTable(context, snapshot);
                    }
                }
              },
            ),
          )
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length;
    }
  }

  Widget _createGitTable(context, snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data["data"].length - 1)
            return GestureDetector(
              onLongPress: () {
                Share.share(
                    snapshot.data["data"][index]["images"]["original"]["url"]);
              },
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapshot.data["data"][index])));
              },
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["original"]
                    ["url"],
                height: 300.0,
                fit: BoxFit.cover,
              ),
            );
          else
            return Container(
              color: Colors.red,
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70,
                    ),
                    Text(
                      "Carregar mais...",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
        });
  }

  Widget _createGitTabble(context, AsyncSnapshot snapshot) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        crossAxisSpacing: 10,
      ),
      itemCount: 19,
      itemBuilder: (context, index) {
        if (_search == null || index < snapshot.data["data"].length - 1) {
          return GestureDetector(
            onLongPress: () {
              Share.share(
                  snapshot.data["data"][index]["images"]["original"]["url"]);
            },
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GifPage(snapshot.data["data"][index]),
                  ));
            },
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["original"]["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),
          );
        } else {
          return Container(
            color: Colors.red,
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.red,
                    size: 70,
                  ),
                  Text(
                    "Carregar mais",
                    style: TextStyle(color: Colors.red, fontSize: 22),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _offset += 18;
                });
              },
            ),
          );
        }
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    final directory = await _getFile();
    String data = json.encode(pesquisas);
    return directory.writeAsString(data);
  }

  Future<String> _getData() async {
    try {
      final directory = await _getFile();
      return directory.readAsString();
    } catch (c) {}
  }
}
