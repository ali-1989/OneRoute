
import 'dart:math';

import 'package:one_route/src/injection_manager.dart';

void main() {
  final im = InjectionManager();

  final kv = <String, dynamic>{};
  kv['k1'] = 'v1';
  kv['k2'] = 'v2';

  im.addInjection('j1', kv);

  final kv2 = <String, dynamic>{};
  kv2['k1'] = 'v1-B';
  kv2['k3'] = 'v3';
  im.addInjection('j1', kv2);

  final res = im.getInjections('j1');
  print(res);


  final s1 = fetchQueryMap('/ali');
  final s1B = fetchQueryMap('/ali?');
  final s1C = fetchQueryMap('/ali?k1');
  final s2 = fetchQueryMap('/hasan?k1=jh');
  final s3 = fetchQueryMap('/hasan?kk1=vv1,k2=hhg,kkk3=v3hy,k4');

  print(s1);
  print(s1B);
  print(s1C);
  print(s2);
  print(s3);
}

Map<String, dynamic> fetchQueryMap(String lastSegment){
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

