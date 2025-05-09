import 'package:flutter/material.dart';

class HomeBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color primaryBlue;
  
  const HomeBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.primaryBlue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          activeIcon: Icon(Icons.search),
          label: 'Rechercher',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: 'Favoris',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          activeIcon: Icon(Icons.list_alt),
          label: 'Mes annonces',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';


// class HomeBottomNavigationBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;
//   final Color primaryBlue;
  
//   const HomeBottomNavigationBar({
//     Key? key,
//     required this.currentIndex,
//     required this.onTap,
//     required this.primaryBlue,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: currentIndex,
//       onTap: onTap,
//       selectedItemColor: primaryBlue,
//       unselectedItemColor: Colors.grey,
//       type: BottomNavigationBarType.fixed,
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home_outlined),
//           activeIcon: Icon(Icons.home),
//           label: 'Accueil',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.search),
//           activeIcon: Icon(Icons.search),
//           label: 'Rechercher',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.favorite_border),
//           activeIcon: Icon(Icons.favorite),
//           label: 'Favoris',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.message_outlined),
//           activeIcon: Icon(Icons.message),
//           label: 'Mes annonces',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.person_outline),
//           activeIcon: Icon(Icons.person),
//           label: 'Profil',
//         ),
//       ],
//     );
//   }
// }