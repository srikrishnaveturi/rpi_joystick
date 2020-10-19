import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:easy_udp_socket/easy_udp_socket.dart';
import 'package:control_pad/control_pad.dart';

void main() {
  runApp(MaterialApp(
    home: Home(
    ),
  ));
}

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String power = 'on';
  String instructionButton = ' ';
  String instructionJoystick = ' ';
  int port = 9999;
  var socket;
  String ipOfReceiver = '192.168.0.103';

  void createSocket() async {
    socket = await EasyUDPSocket.bindBroadcast(port);
  }

  void sendPacket(socket) async{

    try {
      if (socket != null) {
        socket.send(ascii.encode('$instructionButton $instructionJoystick'), ipOfReceiver, port);
      }
      else {
        await socket.close();
      }
    } on Exception catch (e) {
      // `close` method of EasyUDPSocket is awaitable.
      await socket.close();
      print('Client $port closed');

      socket = await EasyUDPSocket.bindBroadcast(port);
    }
  }

  JoystickDirectionCallback onDirectionChanged(double degrees, double distance){
    instructionJoystick = '${degrees.toStringAsFixed(2)} ${distance.toStringAsFixed(2)}';
    print('$instructionButton $instructionJoystick');
    sendPacket(socket);
  }

  @override
  void initState() {
    createSocket();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rpi Control'),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              JoystickView(onDirectionChanged: onDirectionChanged,),
              //SizedBox(width: 10.0,),
              RaisedButton(
                onPressed: () {
                  setState(() {
                    instructionButton = power;
                    power = power == 'on' ? 'off' : 'on';
                    print('$instructionButton $instructionJoystick');
                  });
                  sendPacket(socket);
                },
                child: Text('Turn the led $power'),
              ),
            ],
          )
      ),
    );
  }
}

