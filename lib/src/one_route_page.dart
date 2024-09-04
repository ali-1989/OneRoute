import 'package:flutter/material.dart';
import 'package:one_route/src/injection_manager.dart';


typedef RouteViewBuilder = Widget Function(BuildContext context, String name);
///=============================================================================
class OneRoutePage {
  static final List<OneRoutePage> _routeList = [];
  static final InjectionManager _injectionManager = InjectionManager();
  static bool autoClearInjectionsAfterPop = true;
  final String routeName;
  late RouteViewBuilder viewBuilder;
  int pushCount = 0;
  dynamic data;

  void _init(){
    /// MaterialApp.home >> /
    if(routeName == '/'){
      throw Exception('This is a reserved name, [/].That cannot be selected for routes.');
    }

    for(final i in _routeList){
      if(i.routeName == routeName){
        throw Exception('This is a duplicate name, [$routeName]. Duplicate name cannot be selected for routes.');
      }
    }

    _routeList.add(this);
  }

  /// This route is do add to Routes-list automatic.
  OneRoutePage(String routeName) : routeName = routeName.toLowerCase() {
    _init();
  }

  /// This route is automatically added to the route list.
  OneRoutePage.by(String routeName, this.viewBuilder) : routeName = routeName.toLowerCase() {
    _init();
  }

  void setViewBuilder(RouteViewBuilder builder){
    viewBuilder = builder;
  }

  static List<OneRoutePage> getRouteList(){
    return _routeList;
  }

  static OneRoutePage? findRoute(String name){
    String ckName = name.toLowerCase();

    for(final i in _routeList){
      if(i.routeName == ckName){
        return i;
      }
    }

    return null;
  }

  static bool addRoute(OneRoutePage route){
    for(final i in _routeList){
      if(i.routeName == route.routeName){
        return false;
      }
    }

    _routeList.add(route);
    return true;
  }

  static void removeRoute(String name){
    String ckName = name.toLowerCase();

    _routeList.removeWhere((element) => element.routeName == ckName);
    clearInjections(name);
  }

  void addInjectionItem(String key, dynamic value){
    addInjectionItems({key: value});
  }

  void addInjectionItems(Map<String, dynamic> items){
    _injectionManager.addInjection(routeName, items);
  }

  dynamic getInjectionItem(String routeName, String key){
    return getInjectionItems()?[key];
  }

  dynamic getFirstInjectionItem(String routeName){
    return getInjectionItems()?.values.first;
  }

  Map<String, dynamic>? getInjectionItems(){
    return _injectionManager.getInjections(routeName);
  }

  void clearInjectionItems(){
    _injectionManager.clear(routeName);
  }

  static void addInjection(String routeName, String key, dynamic value){
    addInjections(routeName, {key: value});
  }

  static void addInjections(String routeName, Map<String, dynamic> items){
    _injectionManager.addInjection(routeName, items);
  }

  static dynamic getInjection(String routeName, String key){
    return getInjections(routeName)?[key];
  }

  static dynamic getFirstInjection(String routeName){
    return getInjections(routeName)?.values.first;
  }

  static Map<String, dynamic>? getInjections(String routeName){
    return _injectionManager.getInjections(routeName);
  }

  static void clearInjections(String routeName){
    _injectionManager.clear(routeName);
  }

  static void clearAllInjections(){
    _injectionManager.clearAll();
  }
}
