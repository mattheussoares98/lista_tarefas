import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

List _list = ['teste', 'teste'];

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    String? tarefaNova;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Lista de tarefas'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _list.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                CheckboxListTile(
                  title: Text(_list[index]),
                  value: false,
                  onChanged: (bool? value) {
                    setState(() {});
                  },
                ),
                const Divider(
                  height: 1,
                  color: Colors.black,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.purple,
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    'Tarefa',
                    textAlign: TextAlign.center,
                  ),
                  content: TextFormField(
                    decoration: const InputDecoration(
                      label: Text('Digite a tarefa'),
                    ),
                    onChanged: (value) {
                      tarefaNova = value;
                      print(tarefaNova);
                    },
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (tarefaNova!.isNotEmpty) {
                                _list.add(tarefaNova);
                              }
                            });
                            print(_list);
                            Navigator.of(context).pop();
                          },
                          child: const Text('Salvar'),
                        ),
                      ],
                    ),
                  ],
                );
              });
        },
      ),
    );
  }
}
