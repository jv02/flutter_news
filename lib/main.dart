import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(NewsApp());
}

class NewsApp extends StatefulWidget {
  @override
  _NewsAppState createState() => _NewsAppState();
}

class _NewsAppState extends State<NewsApp> {
  dynamic _newsCards = [];
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        accentColor: Colors.pinkAccent,
      ),
      home: Scaffold(
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              Container(
                width: double.maxFinite,
                height: 200,
                color: Colors.yellow,
                child: Center(child: Text('News App')),
              ),
              InkWell(
                onTap: () {},
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About'),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              _page++;
              _newsCards = [];
            });
          },
          label: const Text('Next'),
          icon: const Icon(Icons.navigate_next),
        ),
        appBar: AppBar(
          actions: <Widget>[
            Center(
              child: Text(_page.toString()),
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _newsCards = [];
                });
              },
            ),
          ],
          title: Text('News App'),
        ),
        body: _newsCards.isNotEmpty
            ? ListView(
                children: <Widget>[
                  ..._newsCards,
                ],
              )
            : FutureBuilder(
                future: getNewsData(),
                builder: (BuildContext buildContext, AsyncSnapshot snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    _newsCards =
                        snapshot.data['response']['results'].map((newsItem) {
                      return InkWell(
                        onTap: () async {
                          if (await canLaunch(newsItem['webUrl']))
                            await launch(newsItem['webUrl']);
                        },
                        splashColor: Colors.pinkAccent,
                        child: Card(
                          margin: EdgeInsets.all(8),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: newsItem['fields']['thumbnail'] == null
                                    ? Container()
                                    : Image.network(
                                        newsItem['fields']['thumbnail']),
                              ),
                              Container(
                                margin: EdgeInsets.all(12),
                                child: Text(
                                  newsItem['fields']['headline']
                                      .toString(), // HeadLine
                                  style: TextStyle(fontSize: 18,),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                    return ListView(
                      children: <Widget>[
                        ..._newsCards,
                      ],
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
      ),
    );
  }

  Future getNewsData() {
    return http
        .get(
            'https://content.guardianapis.com/search?api-key=10d31530-2574-44f6-855e-c9e04f106a9c&show-fields=headline,thumbnail&show-tags=contributor&page-size=10&page=$_page')
        .then((newsData) {
      return json.decode(utf8.decode(newsData.bodyBytes));
    });
  }
}
