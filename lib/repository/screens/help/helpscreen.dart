import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('support_messages');

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Add user message to Firestore
    await _messagesCollection.add({
      'sender': 'user',
      'text': text,
      'time': FieldValue.serverTimestamp(),
    });

    _controller.clear();
    _scrollToBottom();

    // Simulate bot response after a short delay
    Future.delayed(const Duration(seconds: 1), () async {
      String botReply = _generateBotReply(text);

      await _messagesCollection.add({
        'sender': 'bot',
        'text': botReply,
        'time': FieldValue.serverTimestamp(),
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _generateBotReply(String userMessage) {
    final msg = userMessage.toLowerCase();

    if (msg.contains('hello') || msg.contains('hi')) {
      return "Hello! 👋 How can I help you today?";
    } else if (msg.contains('problem') || msg.contains('issue')) {
      return "I'm sorry to hear that. Could you please describe the issue in detail?";
    } else if (msg.contains('booking')) {
      return "You can manage your bookings in the 'Bookings' section of the app.";
    } else if (msg.contains('price') || msg.contains('cost')) {
      return "Our pricing depends on the service. Could you specify what you're looking for?";
    } else if (msg.contains('service') || msg.contains('services')) {
      return "We offer a variety of services. Please check the 'Services' section for more details.";
    } else if (msg.contains('account') || msg.contains('profile')) {
      return "You can manage your account settings in the 'Account' section of the app.";
    } else if (msg.contains('help') || msg.contains('support')) {
      return "For immediate assistance, please contact our support team via email or phone.";
    } else if (msg.contains('thanks') || msg.contains('thank you')) {
      return "You're welcome! If you have any other questions, feel free to ask.";
    } else if (msg.contains('bye') || msg.contains('goodbye')) {
      return "Goodbye! 👋 If you need help in the future, just reach out.";
    } else if (msg.contains('contact') || msg.contains('reach out')) {
      return "You can contact us at support@houzy.com or call us at +1234567890.";
    } else if (msg.contains('feedback') || msg.contains('suggestion')) {
      return "We appreciate your feedback! Please send your suggestions to houz@gmail.com.";
    } else if (msg.contains('hours') || msg.contains('open')) {
      return "Our support team is available from 9 AM to 6 PM, Monday to Friday.";
    } else if (msg.contains('location') || msg.contains('address')) {
      return "We are located at 8th floor office no 36 in zirakpur Sushma Infinium. You can find us on the map in the app.";
    } else if (msg.contains('complaint') || msg.contains('issue')) {
      return "We take complaints seriously. Please provide details about your issue, and we will address it promptly.";
    } else if (msg.contains('payment') || msg.contains('transaction')) {
      return "For payment-related queries, please check the 'Payments' section in your account or contact our support team.";   
    } else if (msg.contains('schedule') || msg.contains('appointment')) {
      return "You can schedule an appointment through the 'Bookings' section. If you need help, let us know!";
    } else if (msg.contains('cancel') || msg.contains('delete')) {
      return "To cancel or delete a booking, go to the 'Bookings' section and select the booking you want to modify.";
    } else if (msg.contains('update') || msg.contains('change')) {
      return "To update your profile or settings, go to the 'Account' section and make the necessary changes.";
    } else if (msg.contains('privacy') || msg.contains('data')) {
      return "We take your privacy seriously. Please read our Privacy Policy in the app for more details.";
    } else if (msg.contains('security') || msg.contains('safety')) {
      return "Your security is our priority. We use industry-standard encryption to protect your data.";
    } else if (msg.contains('feature') || msg.contains('functionality')) {
      return "We are constantly improving our app. If you have a specific feature in mind, please let us know!";
    } else if (msg.contains('issue') || msg.contains('problem')) {
      return "I'm sorry to hear that you're facing an issue. Could you please provide more details so we can assist you better?";
    } else if (msg.contains('complaint') || msg.contains('grievance')) {
      return "We take complaints seriously. Please describe your grievance, and we will do our best to resolve it.";
    } else if (msg.contains('suggestion') || msg.contains('idea')) {
      return "We love hearing suggestions! Please share your idea, and we'll consider it for future updates.";
    } else if (msg.contains('feedback') || msg.contains('review')) {
      return "Your feedback is valuable to us! Please let us know what you think about our app or services.";
    } else if (msg.contains('issue') || msg.contains('problem')) {
      return "I'm sorry to hear that you're facing an issue. Could you please provide more details so we can assist you better?";
    } else if (msg.contains('complaint') || msg.contains('grievance')) {
      return "We take complaints seriously. Please describe your grievance, and we will do our best to resolve it.";
    } else if (msg.contains('suggestion') || msg.contains('idea')) {
      return "We love hearing suggestions! Please share your idea, and we'll consider it for future updates.";
    } else if (msg.contains('feedback') || msg.contains('review')) {
      return "Your feedback is valuable to us! Please let us know what you think about our app or services.";
    } else if (msg.contains('refund') || msg.contains('return')) {
      return "For refund or return requests, please contact our support team with your order details.";
    } else if (msg.contains('technical') || msg.contains('bug')) {
      return "If you're experiencing a technical issue or bug, please describe it in detail so we can help you resolve it.";
    } 
    else if (msg.contains('Kese ho') || msg.contains('kya haal hai') || msg.contains('kya haal chaal hai')) {
      return "Main theek hoon! Aap kaise hain? 😊";
    } 
    else if (msg.contains('Hal chal') || msg.contains('Kese ho')) {
      return "Badhia bhai tu bta😊.";
    } 
    else if (msg.contains('kya aap meri madad kar sakte ho') || msg.contains('kya aap meri help kar sakte ho')) {
      return "Haan, main aapki madad karne ke liye yahan hoon. Aapko kya samasya hai?";
    }
    else if (msg.contains('kya aap mmeri madad kar sakte hain') || msg.contains('kya aap meri madad kar sakte hain')) {
      return "Our support team is available from 9 AM to 6 PM, Monday to Friday. Feel free to reach out during these hours.";
    }
     else {
      return "Thanks for reaching out! Our team will get back to you soon.";
    }
  }

  Widget _buildMessage(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    final isUser = data['sender'] == 'user';

    final Timestamp? timestamp = data['time'] as Timestamp?;
    final time = timestamp != null
        ? DateFormat('hh:mm a').format(timestamp.toDate())
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/bot_avatar.png'),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                            colors: [Color(0XFFF54A00), Color(0XFFF54A00)])
                        : null,
                    color: isUser ? null : const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 0),
                      bottomRight: Radius.circular(isUser ? 0 : 16),
                    ),
                  ),
                  child: Text(
                    data['text'] ?? '',
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                )
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) const SizedBox(width: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Support Chat'),
        backgroundColor: Color(0XFFF54A00),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesCollection
                  .orderBy('time', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: docs.length,
                  itemBuilder: (context, index) => _buildMessage(docs[index]),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Color(0XFFF54A00),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}