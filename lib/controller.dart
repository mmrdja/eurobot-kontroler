import 'package:eurobot22/configuration_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bt_controller.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';


import 'discovery_page.dart';


// Set instrukcija
//
// a
// Toggle
// Pomeranje poluge za statuu
// brojacStatua
// diamond
//
// b
// Toggle
// Pomeranje nosaca za repliku
// brojacReplika
// extension
//
// c
// Toggle
// Pomeranje serva za vucu
// brojacVuca
// commit
//
// d
// Toggle
// ukljucivanje izabranih vakuum pumpi
// brojacSVakum
// air
//
// e
// Toggle
// ukljucivanje oba vakuma, toglovanje pojedinacnih
// desniLeviSVakum
// sync alt
//
// f
// Toggle
// ukljucivanje desnog vakuma
// desniSVakum
// chevron right
//
// g
// Toggle
// ukljucivanje levog vakuma
// leviSVakum
// chevron left
//
// h - q
// Emituje podatke sa numericke tastature
// Pakuje, redom, u 7-segmentni displej cifre 1-0, respektivno,
// a najvise 4
//
// r
// Toggle
// brojacPod ??? Servo neki
// brojacPod
//
// I
// rotacija desno za n stepeni, jednom ide naredba
// rotate_right
//
// J
// rotacija levo za n stepeni, jednom ide naredba
// rotate_left
//
// F
// forward, uzastopna naredba
//
// B
// backward, uzastopna naredba
//
// R
// right, uzastopna naredba
//
// L
// left, uzastopna naredba
// -> Moguce je promeniti brzinu izvrsavanja naredbi, u joysticku

/// Sam kontroler, ovde se nalaze dugmici

class ControllerPage extends StatefulWidget {
  const ControllerPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ControllerPage> createState() => _ControllerPage();
}

class _ControllerPage extends State<ControllerPage> {

  List<String> strings = ["q", "h", "i", "j", "k", "l", "m", "n", "o", "p"];
  int _counter = 0;
  double _speedSliderValue = 64;
  int _brzinaMotora = 0;
  bool _connected = BTController().connected;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  late final ConfigurationController config;
  String pointsValue = "";

  bool configurationLoaded = false;

  @override
  initState() {
    super.initState();
    loadConfig();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    ]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

  }
  void loadConfig() async {
    config = ConfigurationController(await SharedPreferences.getInstance());
    config.retrieveAllSymbols();
    setState(() {
      configurationLoaded = true;
    });
  }

  void onData(dynamic str) { setState(() {  }); }


  Widget buildActionButton({void Function()? callback, required Widget icon,
    Color? color}) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      child: Ink(
        decoration: ShapeDecoration(
          color: (color ?? Colors.lightBlue),
          shape: CircleBorder(),
        ),
        child: IconButton(
          icon: icon,
          color: Colors.white,
          onPressed: () {
            Vibrate.feedback(FeedbackType.success);
            callback!();
          },
        ),
      ),
    );
  }

  void joystickCtrl(StickDragDetails details) {
    if(details.x > 0.5) {
      Vibrate.feedback(FeedbackType.success);
      sendCommand(Command.desno);
    }
    if(details.x < -0.5) {
      Vibrate.feedback(FeedbackType.success);
      sendCommand(Command.levo);
    }
    if(details.y > 0.5) {
      Vibrate.feedback(FeedbackType.success);
      sendCommand(Command.nazad);
    }
    if(details.y < -0.5) {
      Vibrate.feedback(FeedbackType.success);
      sendCommand(Command.napred);
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void sendCommand(Command cmd) {
    BTController().sendData(config.commands[cmd]!);
  }

  @override
  Widget build(BuildContext context) {
        return Consumer<BTController>(
          builder: (context, notifier, child) {
            if(false) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                        Icon(Icons.bluetooth_disabled, color: Colors.red),
                        Text("Not Connected", style: TextStyle(color: Colors.red))
                      ]),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const DiscoveryPage()));
                        },
                        child: const Text("Scan Devices"),
                      ),
                    ],
                  ),
                )
              );
            }
            if(!configurationLoaded) {
              return const Center(child: CircularProgressIndicator(),);
            }
            return Scaffold(
              body: SafeArea(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 10,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Column(
                            children: [
                              Text("Brzina: ${_speedSliderValue.round()}"),
                              Slider(
                                  value: _speedSliderValue,
                                  max: 255,
                                  divisions: 16,
                                  onChanged: (double value) {
                                    sendCommand(Command.brzina);
                                    BTController().sendData("${value.round()}");
                                    setState(() {
                                       _speedSliderValue = value;
                                    });
                                  }
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,

                        child: Column(

                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                pointsValue,
                                style: const TextStyle(
                                  color: Colors.lightBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24
                                ),
                              ),
                            ),
                            NumericKeyboard(
                                onKeyboardTap: (value)  {
                                  Vibrate.feedback(FeedbackType.success);
                                  pointsValue += value;
                                  setState(() {

                                  });
                                  },
                                textColor: Colors.lightBlue,
                                rightIcon: const Icon(Icons.send),
                                leftIcon: const Icon(Icons.clear),
                                rightButtonFn: () {
                                  Vibrate.feedback(FeedbackType.success);
                                  sendCommand(Command.poeni);
                                  BTController().sendData(pointsValue);
                                  setState(() {
                                  });
                                },
                                leftButtonFn: () {
                                  pointsValue = "";
                                  setState(() {

                                  });},
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 210,
                          bottom: 0,
                          child: Column(
                            children: [
                          //     Text("Vakumi toggle"),
                          //     Row(
                          //     children: [
                          //     buildActionButton(callback: () => {
                          //       BTController().sendData("g")
                          //     }, icon: Icon(Icons.chevron_left)),
                          //     buildActionButton(callback: () => {
                          //       BTController().sendData("f")
                          //     }, icon: Icon(Icons.chevron_right)),
                          //   ],
                          // ),
                          // Text("Ukljuci vakume / Vuca"),
                          //     Row(
                          //       children: [
                          //         buildActionButton(callback: () => {
                          //           BTController().sendData("d")
                          //         }, icon: Icon(Icons.air)),
                          //         buildActionButton(callback: () => {
                          //           BTController().sendData("c")
                          //         }, icon: Icon(Icons.commit)),
                          //       ],
                          //     ),
                              Text("Podizač"),
                              Row(
                                children: [
                                  buildActionButton(callback: () => {
                                    sendCommand(Command.podizac),
                                    }, icon: Icon(Icons.forklift)),
                                ],
                              ),
                              Text("Loptice"),
                              Row(
                                children: [
                                  buildActionButton(callback: () => {
                                    sendCommand(Command.servoGore)
                                  }, icon: const Icon(Icons.arrow_upward)),
                                  buildActionButton(callback: () => {
                                    sendCommand(Command.servoSredina)
                                  }, icon: const Icon(Icons.arrow_left)),
                                  buildActionButton(callback: () => {
                                    sendCommand(Command.servoDole)
                                  }, icon: const Icon(Icons.arrow_downward))
                                ],
                              ),
                            ],
                          )),
                      Positioned(
                        right: 30,
                        bottom: 0,
                        child: Row(

                        children: [
                          buildActionButton(callback: () => {
                            BTController().sendData("e")
                          }, icon: Icon(Icons.sync_alt)),
                          buildActionButton(callback: () {
                          }, icon: Icon(Icons.output)),
                        ],
                      ),),
                      Align(
                        alignment: const Alignment(-0.75,0.35),
                        ///
                        /// Joystick
                        ///
                        ///
                        child: Joystick(mode: JoystickMode.horizontalAndVertical, listener: joystickCtrl),
                      ),
                      Consumer<BTController> (
                        builder: (context, notifier, child) {
                          return Positioned(
                              bottom: 0,
                              child: notifier.connected ?
                          Row(
                            children: const [
                              Icon(Icons.bluetooth_connected, color: Colors.green,),
                              Text("Connected", style: TextStyle(color: Colors.green),),
                            ],
                          ) :
                          Row(
                            children: const [
                              Icon(Icons.bluetooth_disabled, color: Colors.red),
                              Text("Not Connected", style: TextStyle(color: Colors.red)),
                            ],
                          ));
                        }
                      )
                    ],
                  ),
                ),
              )
            );
          }
        );
      }
  }
