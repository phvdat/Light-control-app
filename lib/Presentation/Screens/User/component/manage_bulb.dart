import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:light_controller_app/Data/Models/Bulb.dart';
import 'package:light_controller_app/Logic/Room/cubit/room_cubit.dart';
import 'package:light_controller_app/Presentation/Screens/User/Utils/Adafruit_feed.dart';
import 'package:light_controller_app/Presentation/Screens/User/Utils/mqtt_stream.dart';
import 'package:light_controller_app/constant/constant.dart';

class BulbManageDialog extends StatefulWidget {
  final Bulb bulb;
  final String roomId;
  BulbManageDialog({@required this.bulb, @required this.roomId});
  @override
  _BulbManageDialogState createState() => _BulbManageDialogState();
}

class _BulbManageDialogState extends State<BulbManageDialog> {
  int intensity = 255;
  String topic = "datngotan2000/feeds/light-control.den-1";
  String deviceId;
  bool currentStatus = false;
  AppMqttTransactions myMqtt = AppMqttTransactions();
  @override
  void initState() {
    intensity = widget.bulb.intensity;
    deviceId = widget.bulb.id;
    currentStatus = widget.bulb.currentStatus;
    subscribe(topic);
    super.initState();
  }

  @override
  void dispose() {
    subscribe(topic);
    print("dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Thông tin thiết bị",
        style: kTextStyle,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Device Id:   $deviceId", style: kTextStyle),
          SizedBox(
            height: 10.0,
          ),
          Text("Intensity: $intensity", style: kTextStyle),
          Slider(
            value: intensity.toDouble(),
            min: 0,
            max: widget.bulb.intensity.toDouble(),
            onChanged: (double newValue) {
              setState(() {
                intensity = newValue.round();
              });
            },
          ),
          FlutterSwitch(
            showOnOff: true,
            activeText: "ON",
            inactiveText: "OFF",
            activeColor: kButtonColor,
            onToggle: (val) {
              setState(() {
                currentStatus = val;
              });
            },
            value: currentStatus,
          ),
          StreamBuilder(
              stream: AdafruitFeed.sensorStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                String reading = snapshot.data;
                if (reading == null) {
                  reading = 'no value is available';
                }
                return Text(reading);
              })
        ],
      ),
      actions: <Widget>[
        FlatButton(
          color: Colors.red,
          textColor: Colors.white,
          child: Text('CANCEL'),
          onPressed: () {
            setState(() {
              Navigator.pop(context);
            });
            // BlocProvider.of<RoomCubit>(context)
            //       .updateBulb(widget.roomId, bulb);
          },
        ),
        FlatButton(
            color: Colors.green,
            textColor: Colors.white,
            child: Text('UPDATE'),
            onPressed: () {
              publish(topic, intensity.toString());

            }),
      ],
    );
  }

  void subscribe(String topic) {
    myMqtt.subscribe(topic);
  }

  void unSubscribe(String topic) {}

  void publish(String topic, String value) {
    myMqtt.publish(topic, value);
  }
}
