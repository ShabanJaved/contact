import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  bool isPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    requestPermissionAndFetchContacts();
  }

  Future<void> requestPermissionAndFetchContacts() async {
    if (await Permission.contacts.request().isGranted) {
      fetchContacts();
    } else {
      setState(() {
        isPermissionDenied = true;
      });
    }
  }

  Future<void> fetchContacts() async {
    final Iterable<Contact> contactsList = await ContactsService.getContacts();
    setState(() {
      contacts = contactsList.toList();
      filteredContacts = contacts;
    });
  }

  void filterContacts(String query) {
    final filtered = contacts.where((contact) {
      final displayName = contact.displayName?.toLowerCase() ?? '';
      return displayName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredContacts = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: isPermissionDenied
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Permission to access contacts is denied."),
                  TextButton(
                    onPressed: requestPermissionAndFetchContacts,
                    child: const Text("Request Permission"),
                  ),
                ],
              ),
            )
          : Container(
              color: Colors.green[50],
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SearchBox(onSearch: filterContacts),
                  ),
                  Expanded(
                    child: filteredContacts.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ContactsList(contacts: filteredContacts),
                  ),
                ],
              ),
            ),
    );
  }
}

class SearchBox extends StatelessWidget {
  final Function(String) onSearch;

  const SearchBox({Key? key, required this.onSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onSearch,
      decoration: InputDecoration(
        labelText: 'Search',
        labelStyle: const TextStyle(color: Colors.green),
        prefixIcon: const Icon(Icons.search, color: Colors.green),
        filled: true,
        fillColor: Colors.green[100],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.green),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.greenAccent, width: 2.0),
        ),
      ),
    );
  }
}

class ContactsList extends StatelessWidget {
  final List<Contact> contacts;

  const ContactsList({Key? key, required this.contacts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green,
            child: Text(
              contact.displayName?.substring(0, 1) ?? '',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(contact.displayName ?? ''),
          subtitle: Text(
            contact.phones?.isNotEmpty == true
                ? contact.phones!.first.value!
                : 'No phone number',
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: const Icon(Icons.phone, color: Colors.green),
        );
      },
    );
  }
}
