import 'package:flutter/material.dart';
import 'package:maroro/games/party_tetris.dart';
import 'package:maroro/games/word_search.dart';
import 'package:maroro/main.dart';

class Offline extends StatefulWidget {
  const Offline({super.key});

  @override
  State<Offline> createState() => _OfflineState();
}

class _OfflineState extends State<Offline> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Games'),
      ),
      body: ListView(
        shrinkWrap: false,
        scrollDirection: Axis.vertical,
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              //shape: ,
              style: ListTileStyle.drawer,
              tileColor: secondaryColor,
              title: Text(
                'Party Tetris',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PartyTetrisGame()),
                );
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              //shape: ,
              style: ListTileStyle.drawer,
              tileColor: secondaryColor,
              title: Text(
                'CelebrEase Word search',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WordSearchGame()),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
