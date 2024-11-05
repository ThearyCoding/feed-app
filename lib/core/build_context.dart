import 'package:flutter/material.dart';
import '../injection.dart';
import '../services/api/navigation_service.dart';


/// Global BuildContext
final BuildContext context =
    getIt<NavigationService>().navigationKey.currentContext!;
