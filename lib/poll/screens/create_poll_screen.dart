import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({Key? key}) : super(key: key);

  @override
  _CreatePollScreenState createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _choiceControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  void _addChoiceField() {
    setState(() {
      _choiceControllers.add(TextEditingController());
    });
  }

  void _removeChoiceField(int index) {
    if (_choiceControllers.length > 2) {
      setState(() {
        _choiceControllers.removeAt(index);
      });
    }
  }

  Future<void> _createPoll() async {
    if (_formKey.currentState!.validate()) {
      // Collect question and choices from the form
      String question = _questionController.text;
      List<String> choices = _choiceControllers.map((controller) => controller.text).toList();

      // Send data to the Django backend using the CookieRequest for authentication
      try {
        final request = context.read<CookieRequest>();
        final response = await request.post(
          '/polling-makanan/create/',
          {
            'question': question,
            'choices': choices,
          },
        );

        // Check if the poll creation was successful
        if (response.statusCode == 201) {
          // Successfully created poll
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Poll created successfully!')),
          );
          Navigator.pop(context); // Go back to the previous screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create poll')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Poll'),
        backgroundColor: const Color(0xFFFF9900),
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
              const SizedBox(height: 20),
              ..._choiceControllers.asMap().entries.map((entry) {
                int idx = entry.key;
                TextEditingController controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(labelText: 'Choice ${idx + 1}'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a choice';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () => _removeChoiceField(idx),
                      ),
                    ],
                  ),
                );
              }).toList(),
              ElevatedButton(
                onPressed: _addChoiceField,
                child: const Text('Add Choice'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createPoll,
                child: const Text('Create Poll'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
