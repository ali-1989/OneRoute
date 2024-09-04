import 'dart:collection';
import 'dart:core' as core;
import 'dart:core';


class StackList<T> {
  static const int noLimitSize = -1;

  final ListQueue<T> _list = ListQueue();

  /// the maximum number of entries allowed on the stack. -1 = no limit.
  int _sizeMax = 0;

  StackList() {
    _sizeMax = noLimitSize;
  }

  StackList.sized(int max) {
    if(max < 2) {
      throw Exception(
          'Error: stack size must be 2 entries or more '
      );
    }
    else {
      _sizeMax = max;
    }
  }

  bool get isEmpty => _list.isEmpty;

  bool get isNotEmpty => _list.isNotEmpty;

  int get length => _list.length;

  void push(T e) {
    if(_sizeMax == noLimitSize || _list.length < _sizeMax) {
      _list.addLast(e);
    }
    else {
      throw Exception(
          'Error: cannot add element. Stack already at maximum size of: $_sizeMax elements');
    }
  }

  T pop() {
    if (isEmpty) {
      throw Exception(
        'Can\'t use pop with empty stack\n consider '
            'checking for size or isEmpty before calling pop',
      );
    }

    T res = _list.last;
    _list.removeLast();

    return res;
  }

  List<T> popUntil(T until) {
    final ret = <T>[];

    if (isNotEmpty) {
      T res = _list.last;

      for(int i=0; i< _list.length; i++){
        if(res == until) {
          break;
        }

        ret.add(_list.removeLast());

        if(_list.isNotEmpty) {
          res = _list.last;
        }
      }
    }

    return ret;
  }

  List<T> popUntilTest(bool Function(T until) test) {
    final ret = <T>[];

    if (isNotEmpty) {
      T res = _list.last;

      for(int i=0; i< _list.length; i++){
        if(!test(res)) {
          break;
        }

        ret.add(_list.removeLast());

        if(_list.isNotEmpty) {
          res = _list.last;
        }
      }
    }

    return ret;
  }

  T top() {
    if (isEmpty) {
      throw Exception(
        'Can\'t use top with empty stack\n consider '
            'checking for size or isEmpty before calling top',
      );
    }

    return _list.last;
  }

  bool contains(T x) {
    return _list.contains(x);
  }

  void clear() {
    while (isNotEmpty) {
      _list.removeLast();
    }
  }

  List<T> toList() => _list.toList();
}