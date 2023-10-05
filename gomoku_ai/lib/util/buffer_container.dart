import 'dart:ui';

import '../model/chessman.dart';

// 泛型类BufferMap<V>，实现了一个缓冲区（buffer）的功能
// BufferMap的用处在于记录和管理最近的几个棋盘状态。它可以用于实现游戏的一些功能，例如：
// 悔棋功能：如果玩家想要悔棋，可以通过BufferMap中的历史记录回退到之前的棋盘状态，从而实现悔棋操作。
// 撤销操作：当玩家进行某些操作后，发现操作结果不符合预期，可以利用BufferMap中的历史记录撤销该操作，恢复到之前的棋盘状态。
// 历史记录展示：通过BufferMap中保存的棋盘状态，可以展示游戏的历史记录，供玩家回顾以及分析棋局发展。
// AI训练：对于AI算法的训练过程中，可以使用BufferMap来保存训练数据中的棋盘状态，以便进行样本回放、经验重放等技术。
class BufferMap<V> {
  //设置缓冲区为3
  num maxCount = 3;
  final Map<num, V> buffer = {};

  BufferMap();

  BufferMap.maxCount(this.maxCount);

// 添加元素（key存的是每个棋子的分数，value是每个棋子的offset）
  void put(num key, V value) {
    buffer.update(key, (V val) {
      return value;
    },
        //当缓冲区中不存在指定键时，会执行该回调函数来添加新的键值对。
        ifAbsent: () {
      return value;
    });
    _checkSize();
  }

  // 批量添加元素
  void putAll(BufferMap<V> map) {
    for (var entry in map.buffer.entries) {
      buffer[entry.key] = entry.value;
    }
  }

// 检查并缩减缓冲区大小
  void _checkSize() {
    //将缓冲区的所有键转换成列表，并赋值给变量 list，按照从大到小排列
    var list = buffer.keys.toList()
      ..sort((num a, num b) {
        return b.compareTo(a);
      });
    while (buffer.length > maxCount) {
      buffer.remove(list.last);
    }
  }

// 将缓冲区转为Map
  Map<num, V> toMap() {
    return Map<num, V>.from(buffer);
  }

// 获取所有元素的值
  Iterable<V> values() {
    return buffer.values;
  }

// 获取缓存元素个数
  int size() {
    return buffer.length;
  }

// 转为字符串表示
  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    sb.write("{");
    var keys = buffer.keys.toList()
      ..sort((num a, num b) {
        return b.compareTo(a);
      });

    for (var i in keys) {
      sb.write("[$i , ${buffer[i]}] ,");
    }

    return "${sb.toString().substring(0, sb.toString().length - 2)}}";
  }

  // 获取第一个元素的值
  V? get first => buffer[buffer.keys.toList()
    ..sort((num a, num b) {
      return b.compareTo(a);
    })
    ..first];

// 获取键的最小值
  num minKey() {
    if (buffer.isEmpty) {
      return double.negativeInfinity;
    }
    var list = buffer.keys.toList()
      ..sort((num a, num b) {
        return b.compareTo(a);
      });
    return list.isNotEmpty ? list.last : double.negativeInfinity;
  }

// 获取键值最小的元素
  MapEntry<num, V>? min() {
    if (buffer.isEmpty) {
      return null;
    }
    var list = buffer.keys.toList()
      ..sort((num a, num b) {
        return b.compareTo(a);
      });
    return list.isNotEmpty ? MapEntry(list.last, buffer[list.last]!) : null;
  }

  // 获取所有键的列表
  List<num> get keySet {
    if (buffer.isEmpty) return [];

    var sortedKeys = buffer.keys.toList()
      ..sort((num a, num b) {
        return (b - a).toInt();
      });

    return sortedKeys;
  }

// 通过键访问元素的值
  V? operator [](Object? key) {
    return buffer[key];
  }

// 获取键的最大值
  // 最优位置得分
  num maxKey() {
    if (buffer.isEmpty) {
      return double.negativeInfinity;
    }
    var list = buffer.keys.toList()
      ..sort((num a, num b) {
        return b.compareTo(a);
      });
    return list.isNotEmpty ? list.first : 0;
  }

  // 获取键值最大的元素
  // MapEntry 提供了 key 和 value 两个只读属性来获取键和值，分别返回对应键值对的键和值。在 Map 中使用迭代器遍历时，每个元素都是 MapEntry 类型的实例。
  MapEntry<num, V>? max() {
    if (buffer.isEmpty) {
      return null;
    }
    var list = buffer.keys.toList()
      ..sort((num a, num b) {
        return b.compareTo(a);
      });
    return list.isNotEmpty ? MapEntry(list.first, buffer[list.first]!) : null;
  }
}

class OffsetList {
  final List<Offset> buffer = List.empty(growable: true);

  void add(Offset offset) {
    for (Offset o in buffer) {
      if (offset.dy == o.dy && offset.dx == o.dx) {
        return;
      }
    }
    buffer.add(offset);
  }

  void addAll(Iterable<Offset> list) {
    if (list.isNotEmpty) {
      for (Offset o in list) {
        add(o);
      }
    }
  }

  List<Offset> toList() {
    return buffer;
  }

  OffsetList();
}

class BufferChessmanList {
  final List<Chessman> buffer = List.empty(growable: true);
  int maxCount = 5;

  void add(Chessman chessman) {
    buffer.add(chessman);
    _checkSize();
  }

  BufferChessmanList.maxCount({this.maxCount = 5});

  void _checkSize() {
    buffer
      ..sort((Chessman a, Chessman b) {
        return b.score - a.score;
      });

    while (buffer.length > maxCount) {
      buffer.remove(buffer.last);
    }
  }

  List<Offset> toList() {
    List<Offset> list = List.empty(growable: true);
    for (Chessman c in buffer) {
      list.add(c.position);
    }
    return list;
  }

  num minScore() {
    if (buffer.isEmpty) {
      return double.negativeInfinity;
    }
    buffer
      ..sort((Chessman a, Chessman b) {
        return b.score - a.score;
      });
    return buffer.last.score;
  }
}
