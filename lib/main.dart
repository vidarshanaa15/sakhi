import 'package:flutter/material.dart';
import 'package:sakhi_app/core/state/evidence_store.dart';
import 'app.dart';
import 'core/state/sos_store.dart';
import 'backend/supabase/supabase_client.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize(); // required before any async call pre-runApp
  await SosStore.instance.loadContacts();
  await EvidenceStore.instance.load();
  runApp(const SakhiApp()); // or whatever your root widget is called
}