import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


const showComplete = 'show complete';

class SettingsPage extends StatefulWidget {
  final SharedPreferences prefs;
  const SettingsPage({super.key, required this.prefs});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Settings')
        ),
        body: ListView(
          children: [
            Row(children: [
              Switch(
                  key: const Key('completed-switch'),
                  value: widget.prefs.getBool(showComplete) ?? false,
                  onChanged: (bool value) {
                    setState(() {
                      widget.prefs.setBool(showComplete, value);
                    });
                  }),
              Container(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child:  Text(
                    'Show completed item',
                    style: Theme.of(context).textTheme.caption,
                  )),
            ],
            ),
          ],
        )
    );
  }

}