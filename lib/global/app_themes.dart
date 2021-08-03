import 'package:flutter/material.dart';

TextTheme lightTextTheme = TextTheme(
    // bodyText1: GoogleFonts.openSans(
    // fontSize: 14.0,
    // fontWeight: FontWeight.w700,
    // color: Colors.black),
    // headline1: GoogleFonts.openSans(
    // fontSize: 32.0,
    // fontWeight: FontWeight.bold,
    // color: Colors.black),
    // headline2: GoogleFonts.openSans(
    // fontSize: 21.0,
    // fontWeight: FontWeight.w700,
    // color: Colors.black),
    // headline3: GoogleFonts.openSans(
    // fontSize: 16.0,
    // fontWeight: FontWeight.w600,
    // color: Colors.black),
    // headline6: GoogleFonts.openSans(
    // fontSize: 20.0,
    // fontWeight: FontWeight.w600,
    // color: Colors.black),
    );
// 2
TextTheme darkTextTheme = TextTheme(
    // bodyText1: GoogleFonts.openSans(
    // fontSize: 14.0,
    // fontWeight: FontWeight.w600,
    // color: Colors.white),
    // headline1: GoogleFonts.openSans(
    // fontSize: 32.0,
    // fontWeight: FontWeight.bold,
    // color: Colors.white),
    // headline2: GoogleFonts.openSans(
    // fontSize: 21.0,
    // fontWeight: FontWeight.w700,
    // color: Colors.white),
    // headline3: GoogleFonts.openSans(
    // fontSize: 16.0,
    // fontWeight: FontWeight.w600,
    // color: Colors.white),
    // headline6: GoogleFonts.openSans(
    // fontSize: 20.0,
    // fontWeight: FontWeight.w600,
    // color: Colors.white),
    );

AppBarTheme appBarTheme = AppBarTheme(
  backgroundColor: Colors.transparent,
  elevation: 0.0,
);
//
ThemeData light() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.white,
    accentColor: Colors.black, //.grey[900],
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.green,
    ),
    textTheme: lightTextTheme,
    appBarTheme: appBarTheme,
  );
}

// 4
ThemeData dark() {
  return ThemeData(
    brightness: Brightness.dark,

    textTheme: darkTextTheme,
    appBarTheme: appBarTheme,
    //
    primaryColor: Colors.black, //.grey[900],
    accentColor: Colors.white70,
    //
    //canvasColor: Colors.black87,
    //dividerColor: Colors.grey.shade100,
    //cardColor: Colors.grey.shade600,
  );
}
