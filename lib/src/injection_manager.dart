
class InjectionManager {
  final List<_Inject> _injects = [];

  InjectionManager();

  void addInjection(String key, Map<String, dynamic> kv){
    final inj = _getInjection(key);

    inj.kv.addAll(kv);
  }

  _Inject _getInjection(String key){
    for(final x in _injects){
      if(x.key == key.toLowerCase()){
        return x;
      }
    }

    final i = _Inject(key.toLowerCase());
    _injects.add(i);

    return i;
  }

  _Inject? _findInjection(String key){
    for(final x in _injects){
      if(x.key == key.toLowerCase()){
        return x;
      }
    }

    return null;
  }

  Map<String, dynamic>? getInjections(String key){
    return _findInjection(key)?.kv;
  }

  void clear(String key){
    _injects.removeWhere((element) => element.key == key);
  }

  void clearAll(){
    _injects.clear();
  }
}
///=============================================================================
class _Inject {
  String key;

  Map<String, dynamic> kv = {};

  _Inject(this.key);
}