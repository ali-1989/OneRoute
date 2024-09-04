import 'dart:html' as html;
import 'package:flutter_web_plugins/url_strategy.dart' as web_plugin;

import 'package:flutter/foundation.dart';

void changeAddressBar(String url, {dynamic data, bool reload = false}) async {
  // final location = '${html.window.location.protocol}//${html.window.location.host + (html.window.location.pathname?? '')}';
  // html.window.location.href <==> location
  /// html.window.location.href = xxx   : this do reload page


  data ??= html.window.history.state;
  var base = getBaseWebAddress();

  if(!url.toLowerCase().startsWith(base)){
    if(base.endsWith('/')){
      url = '$base$url';
    }
    else {
      url = '$base/$url';
    }
  }

  url = url.replaceAll('//', '/');
  url = url.replaceFirst(':/', '://');

  await Future.delayed(const Duration(milliseconds: 40));
  if(url == getCurrentWebAddress()){
    return;
  }

  if(reload) {
    // can press Back button
    html.window.history.pushState(data, '', url);
  }
  else {
    // can not press Back button
    html.window.history.replaceState(data, '', url);
  }
}

void clearAddressBar() {
  if(!kIsWeb) {
    return;
  }

  final location = '${html.window.location.protocol}//${html.window.location.host}/';
  html.window.history.replaceState(html.window.history.state, '', location);
}

String getBaseWebAddress() {
  if(!kIsWeb) {
    return '';
  }

  return html.document.baseUri?? '';
}

String getCurrentWebAddress() {
  if(!kIsWeb) {
    return '';
  }

  return html.window.location.href;
}

void simulateBrowserBack() {
  html.window.history.back();
}

bool isPathUrlStrategy(){
  return web_plugin.urlStrategy is web_plugin.PathUrlStrategy;
}

bool isHashUrlStrategy(){
  return (web_plugin.urlStrategy is web_plugin.HashUrlStrategy && !isPathUrlStrategy());
}