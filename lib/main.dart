import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thorswapalyzer/swapaction/bloc/swapaction_bloc.dart';
import 'package:thorswapalyzer/swapaction/view/swap_page.dart';
import 'package:thorswapalyzer/utils/app/configure_nonweb.dart'
    if (dart.library.html) 'package:thorswapalyzer/utils/app/configure_web.dart';

void main() {
  configureApp();
  runApp(MultiBlocProvider(providers: [
    BlocProvider<SwapActionBloc>(create: (context) => SwapActionBloc())
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swapalyzer of Thor',
      onGenerateRoute: (settings) {
        // Handle '/'
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => SwapPage());
        }
        final uri = Uri.parse(settings.name ?? '');
        if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'swap') {
          final txID = uri.pathSegments[1];
          BlocProvider.of<SwapActionBloc>(context)
              .add(SwapActionGetEvent(txID));
          return MaterialPageRoute(
              settings: settings, builder: (context) => SwapPage());
        }
      },
      theme: ThemeData(
          textTheme: TextTheme(
              bodyText1: GoogleFonts.workSans(),
              headline1: GoogleFonts.sansita())
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          ),
      home: SwapPage(),
    );
  }
}
