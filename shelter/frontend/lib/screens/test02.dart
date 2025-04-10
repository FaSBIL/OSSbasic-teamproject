import 'package:flutter/material.dart';
import '../component/input/SearchInput.dart';

class Test02Screen extends StatefulWidget {
  const Test02Screen({Key? key}) : super(key: key);

  @override
  State<Test02Screen> createState() => _Test02ScreenState();
}

class _Test02ScreenState extends State<Test02Screen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 20),
          SearchInput(
            controller: _controller,
            onBackTap: () {
              Navigator.pop(context);
            },
            onChanged: (text) {
              print('入力中: $text');
            },
            onSubmitted: (text) {
              print('検索実行: $text');
            },
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '현재 입력: ${_controller.text}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}