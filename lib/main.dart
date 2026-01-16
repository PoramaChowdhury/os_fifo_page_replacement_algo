import 'package:fifo_page_replacemnt/app/fifo_app.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://kuiplloqypitkfufdldb.supabase.co',
    anonKey: 'sb_publishable_qjdFWA_whqJ9rxn7SGGwLQ_0kAb5xWu',
  );
  runApp(const FifoApp());
}
