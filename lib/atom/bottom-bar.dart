import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class CustomNavigationBar extends StatefulWidget {
  Function(String) changeScreen;

  CustomNavigationBar({super.key, required this.changeScreen});

  @override
  // ignore: library_private_types_in_public_api
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  IconData selectedIcon = Icons.home;

  Color? getColor(status) {
    if (status) {
      return Colors.red[700];
    } else {
      return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.red[300]!.withOpacity(0.5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIcon = Icons.home;
                });
                widget.changeScreen("HOME");
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/Home.png',
                      height: 50,
                      width: 50,
                      color: getColor(selectedIcon == Icons.home)),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIcon = Icons.bookmark;
                });
                widget.changeScreen("BOOKMARK");
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark,
                      color: getColor(selectedIcon == Icons.bookmark)),
                  Text(
                    'BOOKMARK',
                    style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: getColor(selectedIcon == Icons.bookmark)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIcon = Icons.menu;
                  });
                  widget.changeScreen("MENU");
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu,
                        color: getColor(selectedIcon == Icons.menu)),
                    Text(
                      'MENU',
                      style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: getColor(selectedIcon == Icons.menu)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
