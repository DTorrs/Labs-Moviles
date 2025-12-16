import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/message_provider.dart';

class SendMessageScreen extends StatefulWidget {
  final User receiver;
  
  const SendMessageScreen({
    Key? key,
    required this.receiver,
  }) : super(key: key);

  @override
  _SendMessageScreenState createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
  
  Future<void> _sendMessage() async {
    if (_formKey.currentState!.validate()) {
      final messageProvider = Provider.of<MessageProvider>(context, listen: false);
      
      final success = await messageProvider.sendMessage(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        receiverEmail: widget.receiver.email,
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mensaje enviado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(messageProvider.error ?? 'Error al enviar mensaje'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageProvider = Provider.of<MessageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Mensaje'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Destinatario
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(widget.receiver.fullName[0].toUpperCase()),
                ),
                title: Text(widget.receiver.fullName),
                subtitle: Text(widget.receiver.email),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              const SizedBox(height: 16),
              
              // Título del mensaje
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Cuerpo del mensaje
              Expanded(
                child: TextFormField(
                  controller: _bodyController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un mensaje';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Botón de enviar
              ElevatedButton.icon(
                onPressed: messageProvider.isLoading ? null : _sendMessage,
                icon: const Icon(Icons.send),
                label: messageProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('ENVIAR'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}