import 'package:flutter/material.dart';
import '../../core/api/cms_api_service.dart';
import '../../core/services/analytics_service.dart';

class ContactScreen extends StatefulWidget {
  final CmsApiService api;

  const ContactScreen({super.key, required this.api});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);

    try {
      final res = await widget.api.submitContact(
        fullName: _name.text, email: _email.text, subject: _subject.text, message: _message.text,
      );
      if (res.success) {
        AnalyticsService.logContactSubmit();
        setState(() { _sent = true; _sending = false; });
      } else {
        _showError(res.message ?? 'Failed to send');
      }
    } catch (e) {
      _showError('Connection error');
    }
  }

  void _showError(String msg) {
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: _sent
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle, size: 64, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            const Text('Message sent successfully!', style: TextStyle(fontSize: 18)),
          ]))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress, validator: (v) => v?.contains('@') != true ? 'Invalid email' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _subject, decoration: const InputDecoration(labelText: 'Subject', prefixIcon: Icon(Icons.subject)),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _message, decoration: const InputDecoration(labelText: 'Message', alignLabelWithHint: true),
                  maxLines: 5, validator: (v) => v?.isEmpty == true ? 'Required' : null),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, height: 48,
                  child: ElevatedButton(onPressed: _sending ? null : _submit,
                    child: _sending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Send Message'))),
              ]),
            ),
          ),
    );
  }
}
