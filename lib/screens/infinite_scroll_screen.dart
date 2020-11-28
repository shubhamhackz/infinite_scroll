import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:infinite_scroll/models/todo.dart';
import 'dart:developer' as developer;

class InfiniteScrollScreen extends StatefulWidget {
  @override
  _InfiniteScrollScreenState createState() => _InfiniteScrollScreenState();
}

class _InfiniteScrollScreenState extends State<InfiniteScrollScreen> {
  bool _hasMore;
  int _pageNumber;
  bool _isError;
  bool _isLoading;
  final int _todosPerPage = 10;
  List<Todo> _todos;
  final int _nextPageThreshold = 5;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _hasMore = true;
    _pageNumber = 1;
    _isError = false;
    _isLoading = true;
    _todos = [];
    fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Todo',
        ),
        backgroundColor: const Color(0xFF00C32D),
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    if (_todos.isEmpty) {
      if (_isLoading) {
        return Center(
            child: Padding(
          padding: const EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        ));
      } else if (_isError) {
        return Center(
            child: InkWell(
          onTap: () {
            setState(() {
              _isLoading = true;
              _isError = false;
              fetchTodos();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text("Error while loading photos, tap to try agin"),
          ),
        ));
      }
    } else {
      return ListView.builder(
        itemCount: _todos.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _todos.length - _nextPageThreshold) {
            fetchTodos();
          }
          if (index == _todos.length) {
            if (_isError) {
              return Center(
                  child: InkWell(
                onTap: () {
                  setState(() {
                    _isLoading = true;
                    _isError = false;
                    fetchTodos();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text("Error while loading photos, tap to try agin"),
                ),
              ));
            } else {
              return Center(
                  child: Padding(
                padding: const EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ));
            }
          }
          final Todo todo = _todos[index];
          // return Card(
          //   child: Column(
          //     children: <Widget>[
          //       Text(todo.status.toString()),
          //       Padding(
          //         padding: const EdgeInsets.all(16),
          //         child: Text(todo.title,
          //             style: TextStyle(
          //                 fontWeight: FontWeight.bold, fontSize: 16)),
          //       ),
          //     ],
          //   ),
          // );
          return Container(
            padding: new EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: todo.status
                        ? LinearGradient(
                            colors: <Color>[
                              Color(0xFF00DA70),
                              Color(0xFF00C32D),
                            ],
                          )
                        : LinearGradient(
                            colors: <Color>[
                              Color(0xFFF73E3C),
                              Color(0xFFF90000),
                            ],
                          ),
                  ),
                  child: Center(
                    child: todo.status
                        ? Icon(
                            FontAwesomeIcons.check,
                            size: 20.0,
                            color: const Color(0x44000000),
                          )
                        : Icon(
                            FontAwesomeIcons.times,
                            size: 20.0,
                            color: const Color(0x55000000),
                          ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      todo.title.capitalize(),
                      style: TextStyle(
                        fontFamily: 'Merriweather',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
    return Container();
  }

  Future<void> fetchTodos() async {
    try {
      final response = await http
          .get("https://jsonplaceholder.typicode.com/todos?_page=$_pageNumber");
      List<Todo> fetchedTodos =
          Todo.parseData(convert.json.decode(response.body));
      developer.log('Data Received : ${response.body}');
      setState(() {
        _hasMore = fetchedTodos.length == _todosPerPage;
        _isLoading = false;
        _pageNumber = _pageNumber + 1;
        _todos.addAll(fetchedTodos);
      });
    } catch (exception) {
      developer.log('Exception while fetching todos: $exception');
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
