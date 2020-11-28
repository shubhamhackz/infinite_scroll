class Todo {
  int userId;
  int id;
  String title;
  bool status;

  Todo({this.id, this.title, this.status, this.userId});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json["id"],
      userId: json["userId"],
      title: json["title"],
      status: json["completed"],
    );
  }

  static List<Todo> parseData(List<dynamic> list) {
    return list.map((i) => Todo.fromJson(i)).toList();
  }
}
