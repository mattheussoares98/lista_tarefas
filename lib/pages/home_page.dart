import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

Map _works = {};

final _key = GlobalKey<FormState>();
TextEditingController _textController = TextEditingController();

class _HomePageState extends State<HomePage> {
  Future<File> _getFile() async {
    ///pega o diretório de onde os arquivos estão sendo salvos
//o caminho no IOS é diferente do android, mas esse método retorna o caminho
//correto de cada um
    Directory directory = await getApplicationDocumentsDirectory();

//retorna o arquivo que será salvo. Até "dados" é o caminho e o "json" é o formato
//do arquivo que será salvo
    return File('${directory.path}/dados.json');
  }

  _saveFile() async {
//convertendo os dados que serão salvos para String. Assim fica no formato json
    String data = json.encode(_works);

//obtendo o arquivo onde salvará as informações
    File file = await _getFile();

//salvando os arquivos na pasta
    file.writeAsString(data);

    _textController.clear();
  }

  _saveWork() {
    bool _isValid = _key.currentState!.validate();
    print(_textController.text);

    if (!_isValid) {
      return;
    }
    setState(() {
//salvando os dados na lista local antes de salvar no dispositivo

      var id = DateTime.now().microsecondsSinceEpoch;
      print(id);
      _works.putIfAbsent(
        id,
        () => {
          'id': id,
          'work': _textController.text,
          'marked': false,
        },
      );
      print(id);

      // _works.add({
      //   'work': _textController.text,
      //   'marked': false,
      // });
    });
  }

  Future _obteinSavedFiles() async {
    //obtendo o arquivo onde salvará as informações
    File file = await _getFile();

    try {
//logo que instala o app, ainda não possui o arquivo no diretório porque ainda
//não salvou informações e por isso ocorre um erro caso não coloque dentro de um
//try/catch
      String data = await file.readAsString();
      setState(() {
        _works = json.decode(data);
      });
    } catch (e) {
      e;
    }
  }

  _removeFileAndList(int index) {
    setState(() {
      _works.remove(index);
    });
    _saveFile();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _obteinSavedFiles();
  }

  @override
  Widget build(BuildContext context) {
    print(_works);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Lista de tarefas'),
        centerTitle: true,
      ),
      body: _works.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma tarefa foi cadastrada',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _works.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: ValueKey(_works[index]),
                  onDismissed: (direction) {
                    _removeFileAndList(index);
                  },
                  crossAxisEndOffset: 0.6,
                  background: Container(
                    color: Colors.red,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Text(
                          _works[index]['work'],
                        ),
                        value: _works[index]['marked'],
                        onChanged: (bool? value) {
                          setState(() {
                            _works[index]['marked'] = value;
                          });

                          _saveFile();
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
                return Form(
                  key: _key,
                  child: AlertDialog(
                    title: const Text(
                      'Tarefa',
                      textAlign: TextAlign.center,
                    ),
                    content: TextFormField(
                      validator: (_name) {
                        if (_name!.trim().isEmpty) {
                          return 'Preencha o nome';
                        }
                        return null;
                      },
                      controller: _textController,
                      decoration: const InputDecoration(
                        label: Text('Digite a tarefa'),
                      ),
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            child: const Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                              child: const Text('Salvar'),
                              onPressed: () {
                                bool _isValid = _key.currentState!.validate();
                                if (!_isValid) {
                                  print('não está válido');
                                  return;
                                }
                                _saveWork();
                                _saveFile();
                                Navigator.of(context).pop();
                              }),
                        ],
                      ),
                    ],
                  ),
                );
              });
        },
      ),
    );
  }
}
