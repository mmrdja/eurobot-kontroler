import 'package:eurobot22/configuration_controller.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({Key? key}) : super(key: key);

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
   late final ConfigurationController config;
   bool configurationLoaded = false;

   @override
  void initState() {
    // TODO: implement initState
    loadConfiguration();
    super.initState();
  }
  void loadConfiguration() async {
   config = ConfigurationController(await SharedPreferences.getInstance());
   config.retrieveAllSymbols();
    setState(() {
      configurationLoaded = true;
    });
   }
  @override
  Widget build(BuildContext context) {
    if(!configurationLoaded) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }
     return MaterialApp(
       home: Scaffold(
         body: SafeArea(
           child: ListView.builder(
               itemCount: config.commands.length,
               itemBuilder: (context, index) {
                 MapEntry<Command, String> cmd = config.commands.entries.elementAt(index);
                 TextEditingController textEditingController = TextEditingController(text:config.commands[cmd.key]);
                 FocusNode focusNode = FocusNode();
                 return Column(
                   children: [
                     Row(
                       children: [
                         Container(
                           padding: const EdgeInsets.only(left: 20),
                             width: 120,
                             child: Text(cmd.key.name)),
                         Container(
                           width: 48,
                           child: TextField(
                             maxLength: 3,
                            controller: textEditingController,
                            focusNode: focusNode,
                             onEditingComplete: () {
                              focusNode.unfocus();
                              },
                             onChanged: (s) {
                               config.configureCommand(cmd.key, textEditingController.value.text);
                             },
                           ),
                         )
                       ],
                     ),
                   ],
                 );
           }),
         ),
       ),
     );
  }
}
