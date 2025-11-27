import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({required this.child, super.key});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/app/home')) {
      return 0;
    } else if (location.startsWith('/app/notes')) {
      return 1;
    } else if (location.startsWith('/app/messages')) {
      return 2;
    } else if (location.startsWith('/app/profile')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/app/home');
        break;
      case 1:
        context.go('/app/notes');
        break;
      case 2:
        context.go('/app/messages');
        break;
      case 3:
        context.go('/app/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show bottom nav on nested routes (like note detail, create note, etc.)
    final location = GoRouterState.of(context).uri.path;
    final showBottomNav =
        location == '/app/home' ||
        location == '/app/notes' ||
        location == '/app/messages' ||
        location == '/app/profile';

    // If the child is a Scaffold, extract its properties and add bottom nav
    if (child is Scaffold) {
      final scaffold = child as Scaffold;
      return Scaffold(
        key: scaffold.key,
        appBar: scaffold.appBar,
        body: scaffold.body,
        floatingActionButton: scaffold.floatingActionButton,
        floatingActionButtonLocation: scaffold.floatingActionButtonLocation,
        bottomNavigationBar: showBottomNav
            ? NavigationBar(
                selectedIndex: _getCurrentIndex(context),
                onDestinationSelected: (index) => _onItemTapped(context, index),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.note_outlined),
                    selectedIcon: Icon(Icons.note),
                    label: 'Notes',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.message_outlined),
                    selectedIcon: Icon(Icons.message),
                    label: 'Messages',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              )
            : null,
      );
    }

    // If child is not a Scaffold, wrap it in one
    return Scaffold(
      body: child,
      bottomNavigationBar: showBottomNav
          ? NavigationBar(
              selectedIndex: _getCurrentIndex(context),
              onDestinationSelected: (index) => _onItemTapped(context, index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.note_outlined),
                  selectedIcon: Icon(Icons.note),
                  label: 'Notes',
                ),
                NavigationDestination(
                  icon: Icon(Icons.message_outlined),
                  selectedIcon: Icon(Icons.message),
                  label: 'Messages',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }
}
