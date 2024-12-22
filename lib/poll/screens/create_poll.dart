// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

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
  final List<TextEditingController> _choicesControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  Future<void> _createPoll(CookieRequest request) async {
    if (_choicesControllers.length < 2 || _choicesControllers.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Poll must have between 2 and 5 choices.')),
      );
      return;
    }

    const url = 'http://daffa-abhipraya-ngandung.pbp.cs.ui.ac.id/polling-makanan/create/';

    Map<String, dynamic> pollData = {
      'question': _questionController.text,
      'is_active': _isActive.toString(),
      'choices': _choicesControllers
          .where((controller) => controller.text.isNotEmpty)
          .map((controller) => {'choice_text': controller.text})
          .toList(),
    };

    try {
      final response = await request.post(
        url,
        jsonEncode(pollData),
      );

      if (response['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poll created successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to create poll: ${response['error']}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _choicesControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Poll'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                decoration: const InputDecoration(labelText: 'Poll Question'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a question';
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: const Text('Is Active'),
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
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            if (_choicesControllers.length > 2) {
                              setState(() {
                                _choicesControllers.removeAt(index);
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Poll must have at least 2 choices.'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (_choicesControllers.length < 5) {
                    setState(() {
                      _choicesControllers.add(TextEditingController());
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Poll cannot have more than 5 choices.')),
                    );
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Choice'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _createPoll(request);
                  }
                },
                child: const Text('Create Poll'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
