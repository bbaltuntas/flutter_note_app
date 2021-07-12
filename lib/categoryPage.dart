import 'package:flutter/material.dart';
import 'package:flutter_note_app/models/category.dart';
import 'package:flutter_note_app/utils/database_helper.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  DatabaseHelper dbHelper;

  TextEditingController _controllerUpdate = TextEditingController();
  TextEditingController _controllerAdd = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "AddCategory",
        tooltip: "Add Category",
        onPressed: () {
          addCategory(context);
        },
        child: Icon(Icons.map),
      ),
      appBar: AppBar(
        title: Text("Categories"),
      ),
      body: FutureBuilder(
          future: dbHelper.bringCategoryList(),
          builder: (context, AsyncSnapshot<List<Category>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Theme(
                        data: ThemeData(
                          splashColor: Theme.of(context).primaryColor,
                        ),
                        child: ListTile(
                          focusColor: Colors.orange,
                          hoverColor: Colors.green,
                          selectedTileColor: Colors.greenAccent,
                          onLongPress: () {
                            _controllerUpdate.text =
                                snapshot.data[index].categoryName;
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                    title: Text("Update Category"),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                          controller: _controllerUpdate,
                                          decoration: InputDecoration(
                                            labelText: "Category Name",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                      ),
                                      ButtonBar(
                                        children: [
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: Colors.red),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("Cancel")),
                                          ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  dbHelper
                                                      .updateCategory(
                                                          Category.withId(
                                                              snapshot
                                                                  .data[index]
                                                                  .categoryId,
                                                              _controllerUpdate
                                                                  .text))
                                                      .then((value) {
                                                    if (value > 0) {
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  "Category has been updated")));
                                                    }
                                                  });
                                                });
                                              },
                                              child: Text("Update")),
                                        ],
                                      ),
                                    ],
                                  );
                                });
                          },
                          leading: Icon(Icons.map),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Deleting Category"),
                                        actions: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Are you sure to delete the category : '${snapshot.data[index].categoryName}' ? ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17),
                                            ),
                                          ),
                                          ButtonBar(
                                            children: [
                                              OutlinedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("Cancel")),
                                              OutlinedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      dbHelper.deleteCategory(
                                                          snapshot.data[index]
                                                              .categoryId);
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("Delete")),
                                            ],
                                          ),
                                        ],
                                      );
                                    });
                              });
                            },
                          ),
                          title: Text(snapshot.data[index].categoryName),
                        ),
                      ),
                    );
                  });
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  void addCategory(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(title: Text("Add Category"), children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _controllerAdd,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  labelText: "Name of the Category"),
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  var result =
                      await dbHelper.addCategory(Category(_controllerAdd.text));
                  if (result > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Category has been added!")));
                    _controllerAdd.text = "";
                    setState(() {});
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Error!")));
                  }
                },
                child: Text(
                  "Add",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.end,
          ),
        ]);
      },
    );
  }
}
