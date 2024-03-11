import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
enum Command {
  brzina,

  napred,
  nazad,
  levo,
  desno,

  servoUgao, // levog servoa
  servoGore,
  servoDole,
  servoSredina,
  poeni,
  podizac
}
class ConfigurationController with ChangeNotifier {

  Map<Command, String> commands = {};
  static const Map<Command, String> defaultCommands = {
    Command.brzina: "v",
    Command.napred: "w",
    Command.nazad: "s",
    Command.levo: "a",
    Command.desno: "d",
    Command.servoUgao: "o",
    Command.servoGore: "t",
    Command.servoDole: "g",
    Command.servoSredina: "b",
    Command.poeni: "p",
    Command.podizac: "l"
  };

  final SharedPreferences prefs;

  ConfigurationController(this.prefs);

  String retrieveSymbol(Command cmd) {
    String value = "";
    if(prefs.containsKey(cmd.name)) {
      value = prefs.getString(cmd.name) ?? "";
    }
    return value;
  }
  void configureCommand(Command cmd, String symbol) {
    prefs.setString(cmd.name, symbol);
  }
  void retrieveAllSymbols() {
    for (final cmd in Command.values) {
      if(!commands.containsKey(cmd)) {
        String v = retrieveSymbol(cmd);
        if(v != "") {
          commands.putIfAbsent(cmd, () => v);
        }
        else {
          commands.putIfAbsent(cmd, () => defaultCommands[cmd]!);
        }
      }
    }
  }
}