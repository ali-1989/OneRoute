import 'package:flutter/material.dart';
import 'package:one_route/src/one_navigator.dart';

class IrisRouterDelegate<T> extends RouterDelegate<T> with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  /*static IrisRouterDelegate? _instance;

  IrisRouterDelegate._();

  static IrisRouterDelegate<T> instance<T>(){
    _instance ??= IrisRouterDelegate<T>._();

    return _instance! as IrisRouterDelegate<T>;
  }*/

  late final GlobalKey<NavigatorState> _navigatorKey;
  late final Widget _root;

  IrisRouterDelegate(this._navigatorKey, this._root);

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  /*@override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
  }
  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
  }

  Router(
        routerDelegate: AppRouterDelegate.instance(),
        backButtonDispatcher: RootBackButtonDispatcher(),
      )

  */

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      //initialRoute: '/',
      //onUnknownRoute: ,
      onGenerateRoute: OneNavigator.instance().generateRoute,
      observers: [OneNavigator.instance()],
      onPopPage: OneNavigator.onPopPage,
      pages: [
        MaterialPage(child: _root)
      ],
    );
  }

  @override
  Future<bool> popRoute() async {
    return false;
  }

  @override
  Future<void> setNewRoutePath(configuration) async {
    return;
  }
}