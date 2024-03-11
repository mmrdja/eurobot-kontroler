import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// Kontroler koji se brine o konekciji i slanju podataka
class BTController extends ChangeNotifier {

  static BluetoothConnection? connection;
  static bool _connected = false;


  Future<void> connect(String? address) async {
    //try {
      print('Address: ${address}');
      BluetoothConnection connection = await BluetoothConnection.toAddress(address);
      //connection.input?.listen(null).onDone(() => {});
      print('Connected to the device');
      _connected = connection.isConnected;
      notifyListeners();
      BTController.connection = connection;

      connection.input?.listen(null).onDone(() {
      });
    //}
    // catch (exception) {
    //   print(exception.);
    //
    //   print('Cannot connect, exception occured');
    // }
  }

  void disconnect() {
    if(_connected) {
      connection?.finish();
      _connected = false;
    }
    notifyListeners();
  }

  void sendData(String data) {
    if(!_connected) {
      // throw Exception("Not connected!");
    }
    developer.log("Sending ascii: $data (${ascii.encode(data)})");
    connection?.output.add(ascii.encode(data));

  }
  void sendRawData(int data) {
    if(!_connected) {
      // throw Exception('Not connected!');
    }
    developer.log("Sending raw: $data");
    Uint8List list = Uint8List(1);
    list.add(data);
    connection?.output.add(list);
  }
  bool get connected => _connected;

}