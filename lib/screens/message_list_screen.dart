import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'message_screen.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  late String _currentUserId;
  Stream<QuerySnapshot>? _chatsStream;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _initializeStream();
  }

  void _initializeStream() {
    _createResilientStream();
  }

  void _createResilientStream() {
    try {
      // Try with orderBy first
      _chatsStream = FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: _currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .handleError((error) {
        print('Stream error handled: $error');
        // Don't throw the error, just log it
        return null;
      });

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error with orderBy, trying without: $e');
      // Fallback without orderBy
      if (mounted) {
        _chatsStream = FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: _currentUserId)
            .snapshots()
            .handleError((error) {
          print('Fallback stream error handled: $error');
          return null;
        });
        setState(() {});
      }
    }
  }

  String _formatMessageTime(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final messageTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(messageTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${messageTime.day}/${messageTime.month}/${messageTime.year}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Now';
    }
  }

  Widget _buildChatTile(Map<String, dynamic> chatData, String chatId) {
    final participants = List<String>.from(chatData['participants'] ?? []);
    final otherUserId =
        participants.firstWhere((id) => id != _currentUserId, orElse: () => '');
    final lastMessage = chatData['lastMessage'] ?? '';
    final lastMessageTime = chatData['lastMessageTime'] as Timestamp?;
    final lastSenderId = chatData['lastSenderId'] ?? '';

    if (otherUserId.isEmpty) return const SizedBox.shrink();

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFF2563EB),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text('Loading...'),
            subtitle: Text(lastMessage),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final userName = userData?['name'] ?? 'Unknown User';
        final userPhone = userData?['phone'] ?? '';
        final isLastMessageFromMe = lastSenderId == _currentUserId;

        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: 0.5,
              ),
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text(
              userName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                lastMessage.isNotEmpty
                    ? '${isLastMessageFromMe ? "You: " : ""}${lastMessage.length > 30 ? "${lastMessage.substring(0, 30)}..." : lastMessage}'
                    : 'No messages yet',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatMessageTime(lastMessageTime),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessageScreen(
                    chatWithUserId: otherUserId,
                    chatWithUserName: userName,
                    chatWithUserPhone: userPhone,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Helper method to create sample chat data for testing
  Future<void> _createSampleChatData() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      // Create a sample chat
      final chatRef = FirebaseFirestore.instance.collection('chats').doc();

      await chatRef.set({
        'participants': [currentUserId, 'sample_user_id'],
        'lastMessage': 'Hello! This is a sample message.',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create a sample user for the chat
      await FirebaseFirestore.instance
          .collection('users')
          .doc('sample_user_id')
          .set({
        'name': 'Sample User',
        'phone': '+1234567890',
        'email': 'sample@example.com',
        'userType': 'rider',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add a sample message to the chat
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRef.id)
          .collection('messages')
          .add({
        'text': 'Hello! This is a sample message.',
        'senderId': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample chat data created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error creating sample data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create sample data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2563EB),
                Color(0xFF1D4ED8),
                Color(0xFF1E40AF),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF1D4ED8),
                  Color(0xFF1E40AF),
                ],
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your conversations',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chat List
          Expanded(
            child: _chatsStream == null
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: _chatsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF2563EB)),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading messages',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Having trouble connecting to the server',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Retry by reinitializing the stream
                                    _initializeStream();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.refresh, size: 20),
                                  label: const Text(
                                    'Retry',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error details: ${snapshot.error}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF2563EB).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.chat_bubble_outline,
                                    size: 64,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'No Messages Yet',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'When you start messaging with riders or passengers, your conversations will appear here.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 20),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue.shade100,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.lightbulb_outline,
                                            color: Colors.blue.shade600,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'How to start messaging:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '• Go to ride requests\n• Click the "Message" button\n• Start chatting with other users',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.blue.shade600,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Add sample data button
                                ElevatedButton.icon(
                                  onPressed: _createSampleChatData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add_comment, size: 20),
                                  label: const Text(
                                    'Create Sample Chat (For Testing)',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final chats = snapshot.data!.docs;

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chatDoc = chats[index];
                          final chatData =
                              chatDoc.data() as Map<String, dynamic>;
                          return _buildChatTile(chatData, chatDoc.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
