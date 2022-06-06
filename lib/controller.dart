import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:provider/provider.dart';
import 'bt_controller.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';


import 'discovery_page.dart';


/// Set instrukcija
///
/// a
/// Toggle
/// Pomeranje poluge za statuu
/// brojacStatua
///
/// b
/// Toggle
/// Pomeranje nosaca za repliku
/// brojacReplika
///
/// c
/// Toggle
/// Pomeranje serva za vucu
/// brojacVuca
///
/// d
/// Toggle
/// ukljucivanje izabranih vakuum pumpi
/// brojacSVakum
///
/// e
/// Toggle
/// ukljucivanje oba vakuma, toglovanje pojedinacnih
/// desniLeviSVakum
///
/// f
/// Toggle
/// ukljucivanje desnog vakuma
/// desniSVakum
///
/// g
/// Toggle
/// ukljucivanje levog vakuma
/// leviSVakum
///
/// h - q
/// Emituje podatke sa numericke tastature
/// Pakuje, redom, u 7-segmentni displej cifre 1-0, respektivno,
/// a najvise 4
///
/// r
/// Toggle
/// brojacPod ??? Servo neki
/// brojacPod
///
///


class ControllerPage extends StatefulWidget {
  const ControllerPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ControllerPage> createState() => _ControllerPage();
}

class _ControllerPage extends State<ControllerPage> {

  List<String> strings = ["q", "h", "i", "j", "k", "l", "m", "n", "o", "p"];
  int _counter = 0;
  bool _connected = BTController().connected;
  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    ]);  // to hide only bottom bar

    super.initState();

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
      BTController().sendData("R");
    }
    if(details.x < -0.5) {
      Vibrate.feedback(FeedbackType.success);
      BTController().sendData("L");
    }
    if(details.y > 0.5) {
      Vibrate.feedback(FeedbackType.success);
      BTController().sendData("B");
    }
    if(details.y < -0.5) {
      Vibrate.feedback(FeedbackType.success);
      BTController().sendData("F");
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
        return Consumer<BTController>(
          builder: (context, notifier, child) {
            if(!notifier.connected) {
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
            return Scaffold(
              body: SafeArea(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Slider(
                        value: 0,
                        max: 100,
                        divisions: 5,
                        label: "Slider",
                        onChanged: (double value) {
                          setState(() {
                            // _currentSliderValue = value;
                          });
                        }
                        ),
                    ),
                  ),
                      Positioned(
                        left: 0,
                        top: 50,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Slider(
                              value: 0,
                              max: 100,
                              divisions: 5,
                              label: "Slider",
                              onChanged: (double value) {
                                setState(() {
                                  // _currentSliderValue = value;
                                });
                              }
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,

                        child: NumericKeyboard(
                            onKeyboardTap: (value)  {
                              Vibrate.feedback(FeedbackType.success);
                              BTController().sendData(strings[int.parse(value)]);
                            },
                            textColor: Colors.lightBlue,
                            rightButtonFn: () {
                              Vibrate.feedback(FeedbackType.success);
                              setState(() {
                              });
                            },
                            leftButtonFn: () {
                              print('left button clicked');
                            },
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly
                        ),
                      ),
                      Positioned(
                        right: 210,
                          bottom: 0,
                          child: Column(
                            children: [
                              Text("Vakumi toggle"),
                              Row(
                              children: [
                              buildActionButton(callback: () => {
                                BTController().sendData("g")
                              }, icon: Icon(Icons.chevron_left)),
                              buildActionButton(callback: () => {
                                BTController().sendData("f")
                              }, icon: Icon(Icons.chevron_right)),
                            ],
                          ),
                          Text("Ukljuci vakume / Vuca"),
                              Row(
                                children: [
                                  buildActionButton(callback: () => {
                                    BTController().sendData("d")
                                  }, icon: Icon(Icons.air)),
                                  buildActionButton(callback: () => {
                                    BTController().sendData("c")
                                  }, icon: Icon(Icons.commit)),
                                ],
                              ),
                              Row(
                                children: [
                                  buildActionButton(callback: () => {
                                    BTController().sendData("b")
                                  }, icon: Icon(Icons.extension)),
                                  buildActionButton(callback: () => {
                                    BTController().sendData("a")
                                  }, icon: Icon(Icons.diamond)),
                                ],
                              ),
                              Row(
                                children: [
                                  buildActionButton(callback: () => {
                                    BTController().sendData("J")
                                  }, icon: Icon(Icons.rotate_left)),
                                  buildActionButton(callback: () => {
                                    BTController().sendData("I")
                                  }, icon: Icon(Icons.rotate_right)),
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
                          buildActionButton(callback: () => {}, icon: Icon(Icons.rotate_right)),
                        ],
                      ),),
                      Align(
                        alignment: const Alignment(-0.65, 0.65),
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
