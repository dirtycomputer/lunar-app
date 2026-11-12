import 'package:shared_preferences/shared_preferences.dart';
import 'package:lunar_social/services/app_state.dart';
import 'people.dart';
export 'people.dart';

AppState testAppState(SharedPreferences preferences) =>
    AppState(preferences, initialPeople: demoPeople);
