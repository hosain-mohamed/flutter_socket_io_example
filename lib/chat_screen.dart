import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<String> messages = [];
  TextEditingController messageController = TextEditingController();
  late Socket socket;

  @override
  void initState() {
    super.initState();
    connectToSocket();
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  void connectToSocket() {
    socket = io(
      "http://192.168.1.2:3000",
      OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    );
    socket.connect();
    socket.onConnect((data) => debugPrint("Connected to socket"));
    socket.onDisconnect((data) => debugPrint("Disconnect"));
    socket.on("groupChat", (data) {
      setState(() => messages.add(data[0]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Screen")),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(messages[index]),
              );
            },
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: messageController,
                    decoration: const InputDecoration(
                        hintText: "Enter a message",
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none),
                  ),
                ),
                IconButton(
                    onPressed: () => sendMessage(),
                    icon: const Icon(Icons.send))
              ],
            ),
          )
        ],
      ),
    );
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      socket.emit("groupChat", messageController.text);
      messageController.clear();
    }
  }
}
