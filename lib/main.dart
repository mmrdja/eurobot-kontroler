import 'package:eurobot22/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'bt_controller.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'configuration_page.dart';
import 'discovery_page.dart';


void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.bottom,
    SystemUiOverlay.top
  ]);  // to hide only bottom bar

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BTController(),
      builder: (context, provider) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.blue,
          ),
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
        );
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  initState() {

    super.initState();

    ///
    /// Skeniraju se uredjaji i konektuje se na odgovarajuci
    /// Mozda promeniti da se konektuje na fiksni, najbolje ostaviti
    /// opciju
    ///
    //scanDevices();
  }

  ///
  /// Potrebno za inicijalizaciju BTController-a
  ///
  void onData(dynamic str) { setState(() {  }); }

  ///
  /// Generise se dialog za biranje uredjaja
  ///
  // void onGetDevices(List<dynamic> devices) {
  //
  //   Iterable<SimpleDialogOption> options = devices.map((device) {
  //
  //     return SimpleDialogOption(
  //       child: Text(device.keys.first),
  //       onPressed: () { selectDevice(device.values.first); },
  //     );
  //   });
  //
  //   SimpleDialog dialog = SimpleDialog(
  //     title: const Text('Choose a device'),
  //     children: options.toList(),
  //   );
  //
  //   showDialog(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (BuildContext context) { return dialog; }
  //   );
  // }


  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
        return Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text("Kontroler za Eurobot 2023"),
          ),
          body: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Column(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Invoke "debug painting" (press "p" in the console, choose the
              // "Toggle Debug Paint" action from the Flutter Inspector in Android
              // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
              // to see the wireframe for each widget.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Eurobot 2023',
                  style: Theme.of(context).textTheme.headline4,
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const DiscoveryPage()));
                  },
                  child: const Text("Skeniraj robote"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const ControllerPage(title: "Controller")));
                  },
                  child: const Text("Kontroler"),
                ),
                OutlinedButton.icon(onPressed: () {
                  Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ConfigurationPage()));
                }, icon: const Icon(Icons.settings), label: const Text("Podešavanja"),
                ),
                Consumer<BTController>(
                  builder: (context, notifier, child) {
                    return TextButton(onPressed: () {
                      notifier.disconnect();
                    }, child: Text("Diskonektuj"));
                  }
                ),
                Consumer<BTController> (
                    builder: (context, notifier, child) {
                      return notifier.connected ?
                      Row(
                        children: const [
                          Icon(Icons.bluetooth_connected, color: Colors.green,),
                          Text("Konektovan", style: TextStyle(color: Colors.green),),
                        ],
                      ) :
                      Row(
                        children: const [
                          Icon(Icons.bluetooth_disabled, color: Colors.red),
                          Text("Nije konektovan", style: TextStyle(color: Colors.red)),
                        ],
                      );
                    }
                )
              ],
            ),
          ),
        );
      }
  }
