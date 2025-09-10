import 'package:flutter/material.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example messages
    final messages = [
      {'sender': 'Alice', 'text': 'Hello!'},
      {'sender': 'Bob', 'text': 'Hi, how are you?'},
      {'sender': 'Alice', 'text': 'I am good, thanks!'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(message['sender']![0]),
                  ),
                  title: Text(message['sender']!),
                  subtitle: Text(message['text']!),
                );
              },
            ),
          ),
          const Divider(height: 1),
          _MessageInputField(),
        ],
      ),
    );
  }
}

class _MessageInputField extends StatelessWidget {
  const _MessageInputField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                // TODO: Implement send functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}