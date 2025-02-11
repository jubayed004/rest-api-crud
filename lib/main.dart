import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String baseUrl = 'https://api.nstack.in/v1/todos/';
  List data = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _updatedTitleController = TextEditingController();
  final TextEditingController _updatedDescriptionController =TextEditingController();

  ///============ Create a new Todo item===============///
  Future<void> _createData(String title, String description) async {
    if (title.isEmpty || description.isEmpty) {
      Get.snackbar("Error", "Title and description cannot be empty!");
      return;
    }
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "title": title,
          "description": description,
          "is_completed": false
        }),
      );
      if (response.statusCode == 201) {
        Get.snackbar("Success", "Todo added successfully");
        _titleController.clear();
        _descriptionController.clear();
        _fetchData();
      } else {
        Get.snackbar("Error", "Failed to add todo");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
      if (kDebugMode) print("Create error: $e");
    }
  }

  ///========== Fetch all Todo items===============///
  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json.containsKey('items')) {
          setState(() {
            data = json['items'];
          });
        }
      } else {
        Get.snackbar("Error", "Failed to fetch data");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
      if (kDebugMode) print("Fetch error: $e");
    }
  }

  ///================ Delete a Todo item==============///
  Future<void> _deleteData(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl$id'));

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Todo deleted successfully");
        _fetchData();
      } else {
        Get.snackbar("Error", "Failed to delete todo");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
      if (kDebugMode) print("Delete error: $e");
    }
  }

  ///================ Update a Todo item===============///
  Future<void> _updateData(String id, String title, String description) async {
    if (title.isEmpty || description.isEmpty) {
      Get.snackbar("Error", "Title and description cannot be empty!");
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "title": title,
          "description": description,
          "is_completed": false
        }),
      );

      if (response.statusCode == 200) {
        _updatedTitleController.clear();
        _updatedDescriptionController.clear();
        Get.back();
        Get.snackbar("Success", "Todo updated successfully");
        _fetchData();
      } else {
        Get.snackbar("Error", "Failed to update todo");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
      if (kDebugMode) print("Update error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rest API CRUD'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                  hintText: "Enter title",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)))),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                  hintText: "Enter description",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)))),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  _createData(
                    _titleController.text,
                    _descriptionController.text,
                  );
                },
                child: const Text(
                  'Post a new todo',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchData,
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (_, index) {
                    return Card(
                      color: Colors.green,
                      child: ListTile(
                        title: Text(data[index]['title'],
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text(data[index]['description'],
                            style: TextStyle(color: Colors.white)),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Get.defaultDialog(
                                      title: 'ToDo Update List',
                                      content: SizedBox(
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              controller:
                                                  _updatedTitleController,
                                              decoration: const InputDecoration(
                                                  hintText: "Enter title"),
                                            ),
                                            TextFormField(
                                              controller:
                                                  _updatedDescriptionController,
                                              decoration: const InputDecoration(
                                                  hintText:
                                                      "Enter description"),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    _updateData(
                                                        data[index]['_id'],
                                                        _updatedTitleController
                                                            .text,
                                                        _updatedDescriptionController
                                                            .text);
                                                  },
                                                  child: Text('Update TO Do')),
                                            )
                                          ],
                                        ),
                                      ));
                                },
                                icon: const Icon(
                                  Icons.edit_document,
                                  color: Colors.amber,
                                ),
                              ),
                              IconButton(
                                onPressed: () =>Get.defaultDialog(
                                  title: 'Are you sure deleted',
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                     TextButton(onPressed: ()async{
                                      await _deleteData(data[index]['_id']);
                                       Get.back();
                                     }, child: Text('Yes')),
                                     TextButton(onPressed: ()=>Get.back(), child: Text('No')),
                                    ],
                                  )
                                ),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
