import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

List _list = [];

TextEditingController _textController = TextEditingController();
final _key = GlobalKey<FormState>();
bool _isValid = _key.currentState!.validate();

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

  _saveWork() {
    if (!_isValid) {
      return;
    }
    setState(() {
//salvando os dados na lista local antes de salvar no dispositivo
      _list.add({
        'work': _textController.text,
        'marked': false,
      });
    });
  }

  _saveFile() async {
//convertendo os dados que serão salvos para String. Assim fica no formato json
    String data = json.encode(_list);

//obtendo o arquivo onde salvará as informações
    File file = await _getFile();

//salvando os arquivos na pasta
    file.writeAsString(data);

    _textController.clear();
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
        _list = json.decode(data);
      });
    } catch (e) {
      e;
    }
  }

  _removeFileAndList(int index) {
    setState(() {
      _list.removeAt(index);
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Lista de tarefas'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _list.length,
        itemBuilder: (context, index) {
          return _list.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhuma tarefa foi cadastrada',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Dismissible(
                  key: ValueKey(_list[index]),
                  onDismissed: (direction) => _removeFileAndList(index),
                  // confirmDismiss: (direction) => _removeFileAndList(index),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Text(
                          _list[index]['work'],
                        ),
                        value: _list[index]['marked'],
                        onChanged: (bool? value) {
                          setState(() {
                            _list[index]['marked'] = value;
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
                      validator: (value) {
                        if (_textController.text.isEmpty) {
                          return 'Digite algo';
                        }
                        return null;
                      },
                      controller: _textController,
                      decoration: const InputDecoration(
                        label: Text('Digite a tarefa'),
                      ),
                      // onChanged: (value) {
                      // },
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
                              if (!_isValid) {
                                print('não está válido');
                                return;
                              } else {
                                print('está válido');
                                _saveWork();
                                _saveFile();
                                Navigator.of(context).pop();
                              }
                            },
                          ),
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
