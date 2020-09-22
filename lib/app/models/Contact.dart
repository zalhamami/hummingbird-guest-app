import 'package:flutter/material.dart';

enum ContactType { WhatsApp, Email, PhoneNumber }

class Contact {
  int id;
  String value, url, label;
  ContactType type;
  IconData icon;

  Contact({
    this.id,
    this.value,
    this.type,
    this.url,
    this.label,
  });

  Contact.fromResponse(Map<String, dynamic> response) {
    id = response['id'];
    value = response['value'];

    final _type = response['name'] as String;

    switch (_type.toLowerCase()) {
      case 'whatsapp':
        if (value.startsWith('+')) value = value.replaceFirst('+', '');
        if (value.startsWith('0')) value = value.replaceFirst('0', '62');

        type = ContactType.WhatsApp;
        url = 'https://wa.me/$value';
        label = 'WhatsApp';
        icon = Icons.phone;
        break;

      case 'email':
        type = ContactType.Email;
        url = 'mailto:$value';
        label = 'Email';
        icon = Icons.email;
        break;

      case 'phone':
        type = ContactType.PhoneNumber;
        url = 'tel:$value';
        label = 'Phone';
        icon = Icons.phone;
        break;
    }
  }
}
