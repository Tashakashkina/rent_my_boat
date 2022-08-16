import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/owner_form.dart';
import 'screens/screen_bottom_menu.dart';
import 'screens/card/card_detail.dart';
import 'screens/card/card_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '../data/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Разрешение на инициализацию Firebase после вызова runApp
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state!.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  //Переменная _firebaseApp для инициализации во FutureBuilder в home
  final Future<FirebaseApp> _firebaseApp = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) => {setLocale(locale)});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rent My Boat',
      theme: ThemeData(
        fontFamily: 'Montserrat',
      ),
      // успешное построение страницы относительно инициализации  Firebase
      // удалить debagPrint позже
      home: FutureBuilder(
          future: _firebaseApp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              debugPrint('You have an error! ${snapshot.error.toString()}');
              return const Text('Something went wrong!');
            } else if (snapshot.hasData) {
              debugPrint('Firebase initialization is successful!');
              return const HomeScreen();
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        _locale ??= deviceLocale;
        return _locale;
      },
      //localizationsDelegates: AppLocalizations.localizationsDelegates,
      //supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('en', ''),
        Locale('ru', ''),
        Locale('de', ''),
        Locale('es', ''),
      ],
      initialRoute: '/',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/owner_form': (context) => const OwnerForm(),

        '/main_screen_bottom_menu': (context) => const MainScreenBottomMenu(), //тут экраны с боттом меню
        '/card_screen': (context) => const CardScreen(),
        '/card_detail': (context) => const CardDetailsScreen(),
      },
      locale: _locale,
    );
  }
}
