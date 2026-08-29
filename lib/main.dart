import 'package:flutter/material.dart';
import 'package:sakhi_app/core/state/evidence_store.dart';
import 'app.dart';
import 'core/state/sos_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // required before any async call pre-runApp
  await SosStore.instance.loadContacts();
  await EvidenceStore.instance.load();
  runApp(const SakhiApp()); // or whatever your root widget is called
}