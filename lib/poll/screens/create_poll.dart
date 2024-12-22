import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({super.key});
  @override
  _CreatePollScreenState createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  bool _isActive = true;
  List<TextEditingController> _choicesControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  Future<void> _createPoll(CookieRequest request) async {
    final url = 'http://127.0.0.1:8000/polling-makanan/create/';

    // Collecting data
    Map<String, dynamic> pollData = {
      'question': _questionController.text,
      'is_active': _isActive.toString(),
      'choices': _choicesControllers
          .where((controller) => controller.text.isNotEmpty)
          .map((controller) => {'choice_text': controller.text})
          .toList(),
    };

    try {
      // Use CookieRequest for authenticated POST request
      final response = await request.post(
        url,
        jsonEncode(pollData), // Convert the entire payload to a JSON string
      );

      // Check response status
      if (response['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Poll created successfully!')),
        );
        Navigator.pop(context);
      } else {
        print('Full response: $response');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create poll: ${response['error']}')),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred')),
      );
    }
  }


  @override
  void dispose() {
    _questionController.dispose();
    _choicesControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
          title: Text('Create Poll'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _questionController,
                decoration: InputDecoration(labelText: 'Poll Question'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a question';
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: Text('Is Active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _choicesControllers.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _choicesControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Choice ${index + 1}',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _choicesControllers.removeAt(index);
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _choicesControllers.add(TextEditingController());
                  });
                },
                icon: Icon(Icons.add),
                label: Text('Add Choice'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _createPoll(request);
                  }
                },
                child: Text('Create Poll'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
