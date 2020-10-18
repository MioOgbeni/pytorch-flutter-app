import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Handwrite number prediction',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Handwrite number prediction'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Prediction {
  String prediction;
  String probability;

  Prediction(this.prediction, this.probability);

  factory Prediction.fromJson(dynamic json) {
    return Prediction(
        json['class_name'] as String, json['probability'] as String);
  }

  @override
  String toString() {
    return '{ ${this.prediction}, ${this.probability} }';
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final String endPoint = 'https://pytorch-flask-api.herokuapp.com/predict';
  Prediction prediction;
  File file;

  String _prediction;
  String _probability;
  File _image;

  @override
  void dispose() {
    super.dispose();
  }

  void _choose() async {
    file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      //source: ImageSource.gallery,
    );
    if (file != null) {
      prediction = await _upload(file);
      setState(() {
        if (prediction != null) {
          _prediction = prediction.prediction;
          _probability = prediction.probability;
          _image = file;
        }
      });
    }
  }

  Future<Prediction> _upload(File file) async {
    String fileName = file.path.split('/').last;
    print(fileName);

    FormData data = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    Dio dio = new Dio();
    Response response;

    response = await dio
        .post(endPoint, data: data)
        .catchError((error) => print(error));

    var jsonResponse = jsonDecode(response.toString());

    return Prediction.fromJson(jsonResponse);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image != null
                ? Image.file(
                    _image,
                    height: 200,
                    width: 200,
                  )
                : Text(""),
            Text(
              'Prediction:',
            ),
            Text(
              prediction == null ? '##' : _prediction,
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              'Probability:',
            ),
            Text(
              prediction == null ? '0.0%' : _probability,
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _choose();
        },
        tooltip: 'Take a photo',
        child: Icon(Icons.photo_camera),
      ),
    );
  }
}
