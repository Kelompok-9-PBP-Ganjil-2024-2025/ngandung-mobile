import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:ngandung_mobile/poll/screens/result.dart'; // Import your model

class PollCard extends StatefulWidget {
  final String pk;
  final String title;
  final String author;
  final bool isActive;
  final bool viewResult;
  final VoidCallback? onTap;
  final VoidCallback? onDelete; // Callback for delete action
  final VoidCallback? onEdit; // Callback for edit action

  const PollCard({
    super.key,
    required this.pk,
    required this.title,
    required this.author,
    required this.isActive,
    this.viewResult = true,
    this.onTap,
    this.onDelete,
    this.onEdit, // Added onEdit callback
  });

  @override
  _PollCardState createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  late bool isActive;

  @override
  void initState() {
    super.initState();
    isActive = widget.isActive; // Initialize the local state with the initial value
  }

  Future<void> _handleDelete(CookieRequest request, BuildContext context) async {
    Map<String, dynamic> data = {'id': widget.pk};

    try {
      final response = await request.post(
        'http://10.0.2.2:8000/polling-makanan/delete/${widget.pk}/',
        data,
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Trigger the onDelete callback to refetch the polls
        if (widget.onDelete != null) {
          widget.onDelete!();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete the item'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _togglePollStatus(CookieRequest request, BuildContext context) async {
    try {
      final response = await request.post(
        'http://10.0.2.2:8000/polling-makanan/update/${widget.pk}/',
        {},
      );

      if (response['status'] == 'success') {
        setState(() {
          isActive = !isActive; // Toggle the local state
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isActive ? 'Poll opened successfully' : 'Poll closed successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Trigger the onEdit callback to refetch the polls
        if (widget.onEdit != null) {
          widget.onEdit!();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to change poll status'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final String currentUsername = request.jsonData['username'];
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: request.jsonData['is_superuser'] || widget.viewResult ? Colors.green : (isActive ? Colors.blueAccent : Colors.grey),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: InkWell(
          onTap: () {
            if (widget.viewResult) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PollResultScreen(pollId: widget.pk), // Pass pollId as string
                ),
              );
            } else {
              if (widget.onTap != null) {
                widget.onTap!();
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.author,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              widget.viewResult
                                  ? 'View Result | ${widget.isActive ? 'Opened' : 'Closed'}'
                                  : 'Vote | ${widget.isActive ? 'Opened' : 'Closed'}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (true == request.jsonData['is_superuser'] || currentUsername == widget.author)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'toggle') {
                            _togglePollStatus(request, context);
                          } else if (value == 'delete') {
                            _handleDelete(request, context);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              value: 'toggle',
                              child: Text(isActive ? 'Close Poll' : 'Open Poll'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ];
                        },
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

