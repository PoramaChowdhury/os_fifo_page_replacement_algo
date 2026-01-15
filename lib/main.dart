import 'package:fifo_page_replacemnt/fifo_app.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://kuiplloqypitkfufdldb.supabase.co';
const supabaseAnonKey = 'sb_publishable_qjdFWA_whqJ9rxn7SGGwLQ_0kAb5xWu';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const FifoApp());
}