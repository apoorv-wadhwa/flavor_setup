import "package:path/path.dart" show dirname;
import 'dart:io';

void main() async {
  var dirName = dirname(Platform.script.toString()).replaceAll("file:///", '');

  print(' dir name is $dirName');
  final flavorConfig = '$dirName/core/flavors/flavor_config.dart';
  final flavorConstants = '$dirName/core/constants/flavor_constants.dart';
  final devEnv = '$dirName/core/flavors/dev.dart';
  final prodEnv = '$dirName/core/flavors/prod.dart';

  await createFile(
    path: flavorConfig,
    fileData: fileForFlavorConfig,
  );
  await createFile(
    path: flavorConstants,
    fileData: fileFlavorConstants,
  );
  await createFile(
    path: devEnv,
    fileData: devFile,
  );
  await createFile(
    path: prodEnv,
    fileData: prodFile,
  );
  await editMain(dirName);

  await buildGradleEdit();
}

Future buildGradleEdit() async {
  var gradlePath = 'D:/work/KotlinLearningProjects/flavor_management/android/app/build.gradle';
  final myFile = File(gradlePath);
  final splitContent = myFile.readAsStringSync().split('buildTypes');
  // print('${splitContent[0]}');
  // print('    buildTypes');
  // print(' ${splitContent[1]}');
  const flavorDimensionsText = '''flavorDimensions "flavor"''';

  const flavorJson = '''
   productFlavors {
        prod {
            dimension "flavor"
            applicationId "com.example.prod"
            resValue "string", "app_name", "Flavors PROD"

        }
        dev {
            dimension "flavor"
            applicationId "com.example.dev"
            resValue "string", "app_name", "Flavors DEV"
        }
    }
  
  ''';

  final newFile = '''
  ${splitContent[0]}
   $flavorDimensionsText
   $flavorJson
      buildTypes ${splitContent[1]}
      
  ''';

  // print('new gradle file is $newFile');

  myFile.deleteSync();
  myFile.writeAsStringSync(newFile);
}

Future createFile({required String path, required String fileData}) async {
  await File(path).create(recursive: true);
  var myFile = File(path);
  var sink = myFile
      .openWrite(); // for appending at the end of file, pass parameter (mode: FileMode.append) to openWrite()
  sink.write(fileData);
  await sink.flush();
  await sink.close();
}

Future editMain(String path) async {
  var myFile = File('$path/main.dart');
  var content = myFile.readAsStringSync();
  var isMainCommonFuncAvailable = content.contains('mainCommon');
  print('isMainCommonFuncAvailable : $isMainCommonFuncAvailable');
  var replacementContent = '';
  if (!isMainCommonFuncAvailable) {
    final newContent = content.replaceAll('main()', 'mainCommon()');
    replacementContent = '''
    $newContent''';
  } else {
    replacementContent = content;
  }
  myFile.delete();
  await File('$path/main.dart').create(recursive: true);
  var newFile = File('$path/main.dart');
  newFile.writeAsStringSync(replacementContent);
  // print(myFile.toString());
  // var sink = myFile.openWrite();
}

var baseUrl = '';

var enumForFlavors = '''
import 'package:flutter/material.dart';

enum Flavors { prod, dev }
''';

var classFlavorValues = '''

class FlavorValues {
  final String apiBaseUrl;
  final Color color;


  FlavorValues({
    required this.apiBaseUrl,
    this.color = Colors.red,

  });
}
''';

var classFlavorConfig = '''
class FlavorConfig {
  final Flavors flavor;
  final FlavorValues flavorValues;
  static FlavorConfig? _instance;

  FlavorConfig._internal(
    this.flavor,
    this.flavorValues,
  );

  factory FlavorConfig(
      {required Flavors flavor, required FlavorValues flavorValues}) {
    _instance ??= FlavorConfig._internal(flavor, flavorValues);
    return _instance!;
  }

  static String getApiBaseUrl() => _instance?.flavorValues?.apiBaseUrl ?? '';

  static FlavorConfig? get config => _instance;

  static bool isDev() => (_instance?.flavor ?? Flavors.dev) == Flavors.dev;

  static bool isProd() => (_instance?.flavor ?? Flavors.dev) == Flavors.prod;
  
  static Color getFlavorColor() => _instance?.flavorValues.color ?? Colors.red;

}

''';

var fileFlavorConstants = '''

class FlavorConstants {
  static const String baseUrl = "";
}

''';

var fileForFlavorConfig = ''' 

$enumForFlavors 

$classFlavorValues

$classFlavorConfig

''';

var devFile = ''' 
import '../../main.dart';
import 'flavor_config.dart';
import '../constants/flavor_constants.dart';
import 'package:flutter/material.dart';


  void main() {
    FlavorConfig(
    flavor: Flavors.dev,
    flavorValues: FlavorValues(
      apiBaseUrl: FlavorConstants.baseUrl,
      color: Colors.blue,

    ),
  );
  
  mainCommon();
  }
''';

var prodFile = ''' 
import '../../main.dart';
import 'flavor_config.dart';
import '../constants/flavor_constants.dart';
import 'package:flutter/material.dart';



  void main() {
    FlavorConfig(
    flavor: Flavors.prod,
    flavorValues: FlavorValues(
      apiBaseUrl: FlavorConstants.baseUrl,
    ),
  );
  
  mainCommon();
  }
''';
