import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:one_route/one_navigator.dart';
import 'package:one_route/src/stack_list.dart';

import 'package:one_route/src/route_none_web_func.dart'
if (dart.library.html) 'package:one_route/src/route_web_func.dart' as web;


typedef OnNotFound = Route? Function(RouteSettings settings);
typedef OnGenerateRoute = Route? Function(RouteSettings settings, Route? route);
typedef EventListener = void Function(RouteHolder? route, NavigateState state);
///=============================================================================
class RouteHolder {
  late Route route;
  String? routeName;
  String? generatedName;

  String get name => routeName ?? generatedName!;

  RouteHolder(this.route, {String? routeName}){
    this.routeName = routeName?.toLowerCase();
    this.routeName ??= route.settings.name?.toLowerCase();

    if(routeName == null){
      generatedName = _generateKey(route, 7);
    }
  }

  String _generateKey(Route route, int len){
    const s = 'abcdefghijklmnopqrstwxyz123456789';
    var name = '';

    for(var i=0; i<len; i++) {
      final j = Random().nextInt(s.length);
      name += s[j];
    }

    String routeType = 'page';

    if(route is ModalBottomSheetRoute){
      routeType = 'BottomSheet';
    }
    else if(route is RawDialogRoute){
      routeType = 'DialogRoute';
    }
    else if(route is PopupRoute){
      routeType = 'PopupRoute';
    }

    return '$routeType@$name';
  }
}
///=============================================================================
enum NavigateState {
  push,
  pop,
  remove,
}
///=============================================================================
class OneNavigator extends NavigatorObserver  /*NavigatorObserver or RouteObserver*/ {
  static const _log = '▄ONE NAVIGATOR▄';
  final StackList<RouteHolder> _currentRoutedList = StackList();
  final List<EventListener> _eventListener = [];
  OnGenerateRoute? onGenerateRoute;
  OnNotFound? notFoundHandler;
  bool isRestrictName = true;
  bool debugLog = false;
  BuildContext? _buildContext;

  String? _urlPath;
  String? _lastSegment;
  final Map<String, dynamic> _queryMap = {};
  final List<String> _pathSegments = [];

  List<String> get pathSegments => _pathSegments;
  String? get urlPath => _urlPath;
  String? get lastSegment => _lastSegment;
  Map<String, dynamic> get queryMap => _queryMap;

  OneNavigator();

  /*factory OneNavigator.instance(){
    return _instance; static final OneNavigator _instance = OneNavigator._();
  }*/

  void addEventListener(EventListener listener){
    if(!_eventListener.contains(listener)){
      _eventListener.add(listener);
    }
  }

  void removeEventListener(EventListener listener){
    _eventListener.remove(listener);
  }

  void activeUrlHandler(BuildContext context){
    Navigator? nav = context.findAncestorWidgetOfExactType();

    if(nav == null){
      throw Exception('This BuildContext have not a Navigator.');
    }

    _buildContext = context;
  }

  // MaterialNavigatorKey.currentState    <==>    route.navigator
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;

    if(debugLog) {
      debugPrint('$_log  (Push)  name:$name');
    }

    _parseUrl();

    if(name == null){
      if(isRestrictName && route is PageRoute){
        throw Exception('$_log  Page must have a name.');
      }
    }
    else {
      calcPushCounter(name);
    }

    super.didPush(route, previousRoute);
    final rHolder = RouteHolder(route);

    /// MaterialApp.home >> /

    bool isEmpty = _currentRoutedList.isEmpty;
    _currentRoutedList.push(rHolder);


    if(kIsWeb && isEmpty && web.isHashUrlStrategy()){
      final lastPath = _clearToPageName(lastSegment?? '');
      final oneRoute = OneRoutePage.findRoute(lastPath);

      if(oneRoute != null){
        final result = _buildRoute(oneRoute, RouteSettings(name: lastPath));

        Future.delayed(const Duration(milliseconds: 100), (){
          if(_buildContext != null){
            Navigator.of(_buildContext!).push(result);
          }
        });
      }
    }

    if(kIsWeb && web.isPathUrlStrategy() && name != null) {
      _changeAddressBarOnWeb();
    }

    for (final lis in _eventListener) {
      try{
        lis.call(rHolder, NavigateState.push);
      }
      catch (e){/**/}
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;

    if(debugLog) {
      debugPrint('$_log  (Pop)  name:$name');
    }

    super.didPop(route, previousRoute);
    final rHolder = _currentRoutedList.pop();

    if(OneRoutePage.autoClearInjectionsAfterPop) {
      OneRoutePage.clearInjections(rHolder.name);
    }

    if(kIsWeb && web.isPathUrlStrategy() && name != null) {
      _changeAddressBarOnWeb();
    }

    for (final lis in _eventListener) {
      try{
        lis.call(rHolder, NavigateState.pop);
      }
      catch (e){/**/}
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;

    if(debugLog) {
      debugPrint('$_log  (Remove)  name:$name');
    }

    super.didRemove(route, previousRoute);
    final rList = _currentRoutedList.popUntilTest((elm) => elm.route != route);

    if(kIsWeb && web.isPathUrlStrategy() && name != null) {
      _changeAddressBarOnWeb();
    }

    for(final x in rList) {
      if(OneRoutePage.autoClearInjectionsAfterPop) {
        OneRoutePage.clearInjections(x.name);
      }

      for (final lis in _eventListener) {
        try{
          lis.call(x, NavigateState.remove);
        }
        catch (e){/**/}
      }
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    var name = newRoute?.settings.name;

    if(debugLog) {
      debugPrint('$_log  (Replace)  name:$name  FOR  ${oldRoute?.settings.name}');
    }


    if(isRestrictName && name == null && newRoute is PageRoute){
      throw Exception('Page must have a name.');
    }

    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final rHolder = RouteHolder(newRoute!);

    if (name != null) {
      calcPushCounter(name);
    }

    if(kIsWeb && web.isPathUrlStrategy() && name != null) {
      _changeAddressBarOnWeb();
    }

    final remove = _currentRoutedList.pop();

    if(OneRoutePage.autoClearInjectionsAfterPop) {
      OneRoutePage.clearInjections(remove.name);
    }

    _currentRoutedList.push(rHolder);

    for (final lis in _eventListener) {
      try{
        lis.call(remove, NavigateState.remove);
        lis.call(rHolder, NavigateState.push);
      }
      catch (e){/**/}
    }
  }

  void calcPushCounter(String routeName){
    final route = OneRoutePage.findRoute(routeName);
    route?.pushCount++;
  }

  /// this method will call:
  /// on App: when use of Navigator.pushNamed().
  /// on Web: when change address-bar. [www.domain.com/#x]
  /// settings.name == /page1?k1=v1#first
  Route? generateRoute(RouteSettings settings) {
    if(debugLog) {
      debugPrint('$_log  (GenerateRoute)  name:${settings.name}');
    }

    var rName = _clearToPageName(settings.name!);
    final oneRoute = OneRoutePage.findRoute(rName);

    if(web.isPathUrlStrategy() && !rName.startsWith('/')){
      rName = '/$rName';
    }

    ///---- not found oneRoute
    if(oneRoute == null){
      if(notFoundHandler != null){
        return notFoundHandler!.call(settings);
      }

      return null;
    }

    var result = _buildRoute(oneRoute, RouteSettings(name: rName, arguments: settings.arguments));
    result = onGenerateRoute?.call(settings, result)?? result;

    /// if result be null, didPush() will call with '/' address
    return result;
  }

  Route _buildRoute(OneRoutePage oneRoute, RouteSettings settings){
    var name = settings.name!;

    if(web.isPathUrlStrategy() && name.startsWith('/')){
     name = name.substring(1);
    }

    return MaterialPageRoute( //PageRouteBuilder
      builder: (ctx){
        return oneRoute.viewBuilder(ctx, name);
      },
      settings: settings,
    );
  }



  RouteHolder? getLastRoute(){
    if(_currentRoutedList.isEmpty){
      return null;
    }

    return _currentRoutedList.top();
  }

  List<RouteHolder> currentRoutes(){
    return _currentRoutedList.toList();
  }

  /// [reload]: if be false, can not use Back button on browser
  void setAddressBar(String url, {bool reload = false}){
    if(!kIsWeb){
      return;
    }

    web.changeAddressBar(url, reload: reload);
  }

  String domain(){
    return web.getBaseWebAddress();
  }

  String fullUrl(){
    return web.getCurrentWebAddress();
  }

  String _fetchUrlPath(){
    final fullUrl = web.getCurrentWebAddress();
    final baseUrl = web.getBaseWebAddress();

    if(fullUrl.startsWith(baseUrl)){
      return fullUrl.substring(baseUrl.length);
    }

    return fullUrl;
  }

  List<String> _fetchPathSegments(){
    final paths = _fetchUrlPath();
    return paths.split('/');
  }

  String _clearToPageName(String address){
    if(address.endsWith('/')){
      address = address.substring(0, address.length-1);
    }

    if(!address.startsWith('/')){
      address = '/$address';
    }

    final split = address.split('/');
    final last = split.last;

    int idxQuestionMark = last.indexOf('?');
    int idxSharpMark = last.indexOf('#');

    int idx = idxQuestionMark;

    if(idx < 0){
      idx = idxSharpMark;
    }

    if(idx > -1){
      return last.substring(0, idx);
    }

    return last;
  }

  Map<String, dynamic> _fetchQueryMap(){
    final segment = lastSegment?? '';
    var query = segment;

    int idxQuestionMark = segment.indexOf('?');
    int idxSharpMark = segment.indexOf('#');

    int idx = idxQuestionMark;
    final ret = <String, dynamic>{};

    if(idx > -1){
      query = segment.substring(idx+1, idxSharpMark > 0 ? idxSharpMark : segment.length);
    }

    if(idx == -1 || idx+1 == segment.length){
      return ret;
    }


    if(query.contains(',')){
      var sIdx = 0;
      var eIdx = query.indexOf(',');

      while(eIdx <= query.length && eIdx > 0){
        final sp = query.substring(sIdx, eIdx).split('=');

        if(sp.length < 2){
          ret[sp[0]] = null;
        }
        else {
          ret[sp[0]] = sp[1];
        }


        sIdx = eIdx+1;

        if(eIdx >= query.length){
          break;
        }

        eIdx = query.indexOf(',', eIdx+1);

        if(eIdx == -1 && sIdx < query.length-1){
          eIdx = query.length;
        }
      }
    }
    else {
      final sp = query.split('=');

      if(sp.length < 2){
        ret[sp[0]] = null;
      }
      else {
        ret[sp[0]] = sp[1];
      }
    }

    return ret;
  }

  void _parseUrl(){
    if(!kIsWeb){
      return;
    }

    _pathSegments.clear();
    _queryMap.clear();

    _urlPath = _fetchUrlPath();
    _pathSegments.addAll(_fetchPathSegments());
    _lastSegment = _pathSegments.isEmpty ? null : _pathSegments.last;
    _queryMap.addAll(_fetchQueryMap());
  }

  void _changeAddressBarOnWeb() {
    if(!kIsWeb){
      return;
    }

    final base = domain();
    final cur = fullUrl();

    if(cur == base){
      return;
    }

    String url = '/';
    final lastRoute = getLastRoute();

    if(lastRoute != null && lastRoute.name != '/'){
      if(lastRoute.name.startsWith('/')) {
        url = lastRoute.name;
      }
      else {
        url = '/${lastRoute.name}';
      }
    }

    web.changeAddressBar(url);
  }
}