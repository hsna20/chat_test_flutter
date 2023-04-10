// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(
    const MaterialApp(
      title: 'Flutter Chat',
      home: ChatWidget(),
    ),
  );
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget(
      {required this.username,
      required this.message,
      required this.timestamp,
      super.key});

  final String username;
  final String message;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: ListTile(
          leading: Text(timestamp),
          title: Text(username),
          subtitle: Text(
            message,
            style: TextStyle(fontSize: 14),
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  String username = "";
  String message = "";

  late IO.Socket socket;

  @override
  void initState() {
    initSocket();
    super.initState();
  }

  initSocket() {
    socket = IO.io('http://localhost:3000',
        IO.OptionBuilder().setTransports(['websocket']).build());
    socket.connect();

    socket.onConnect((_) {
      openUsernameDialog();
      print('connection established');
    });

    socket.on("messages", (messages) {
      List<Widget> _chatMessages = [];
      for (var message in messages) {
        print(message);

        _chatMessages.add(ChatMessageWidget(
            username: message['username'],
            message: message['message'],
            timestamp: convertTimeStamp(message['created'])));
      }
      setState(() {
        chatMessages = _chatMessages;
      });
    });

    socket.on("message", (message) {
      print(message);
      setState(() {
        chatMessages = [
          ...chatMessages,
          ChatMessageWidget(
              username: message['username'],
              message: message['message'],
              timestamp: convertTimeStamp(message['created']))
        ];
      });
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            curve: Curves.easeOut, duration: const Duration(milliseconds: 50));
      });
    });
  }

  String convertTimeStamp(int timestamp) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String convertedDateTime =
        "${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}-${dateTime.minute.toString().padLeft(2, '0')}";
    return convertedDateTime;
  }

  List<Widget> chatMessages = [
    Card(
      child: ListTile(
        leading: Text("26 Jan, 2022"),
        title: Text("Mohammed"),
        subtitle: Text(
          "Hello world, today is good day",
          style: TextStyle(fontSize: 14),
        ),
        isThreeLine: true,
      ),
    )
  ];

  Future openUsernameDialog() => showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            title: Text("Enter your name to Join Chat"),
            content: TextField(
              onChanged: (value) => username = value,
              decoration: InputDecoration(hintText: "Enter your name"),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Join Chat"))
            ],
          )));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Real-Time Chat",
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text("Dead Simple Chat",
                            style: TextStyle(
                                color: Colors.blue[600],
                                fontSize: 12,
                                fontWeight: FontWeight.bold))
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView(
                      controller: _scrollController, children: chatMessages),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                        child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Chat Message',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  // Handle clear
                                  _textController.clear();
                                },
                              ))),
                    )),
                    GestureDetector(
                      onTap: () {
                        String message = _textController.text;
                        socket.emit("message",
                            {"username": username, "message": message});
                        _textController.clear();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.all(16),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}



















// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   void _callAPI() async {
//     var url = Uri.parse(
//         // 'https://raw.githubusercontent.com/dev-yakuza/users/master/api.json',
//         'http://localhost:3000/');
//     var response = await http.get(url);
//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');

//     url = Uri.parse('https://reqbin.com/sample/post/json');
//     response = await http.post(url, body: {
//       'key': 'value',
//     });
//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             TextButton(
//               onPressed: () {
//                 _callAPI();
//               },
//               child: Text('button'),
//             ),
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
