import 'package:flutter/foundation.dart';

class NetmonBox {
  final String boxId;
  final NetmonBoxDetails details;

  const NetmonBox({
    required this.boxId,
    required this.details,
  });
}

class NetmonBoxDetails {
  final String address;
  final bool trusted;
  final double trust;
  final String trustInfo;
  final bool isSupervisor;
  final String working;
  final bool recent;
  final String deployment;
  final String version;
  final String pyVer;
  final String lastRemoteTime;
  final String nodeTz;
  final String nodeUtc;
  final double mainLoopAvgTime;
  final double mainLoopFreq;
  final String uptime;
  final double lastSeenSec;
  final double availDisk;
  final double availMem;
  final double cpuPast1h;
  final double gpuLoadPast1h;
  final double gpuMemPast1h;
  final double score;

  static const double invalidDoubleValue = -1;

  NetmonBoxDetails({
    required this.address,
    required this.trusted,
    required this.trust,
    required this.trustInfo,
    required this.isSupervisor,
    required this.working,
    required this.recent,
    required this.deployment,
    required this.version,
    required this.pyVer,
    required this.lastRemoteTime,
    required this.nodeTz,
    required this.nodeUtc,
    required this.mainLoopAvgTime,
    required this.mainLoopFreq,
    required this.uptime,
    required this.lastSeenSec,
    required this.availDisk,
    required this.availMem,
    required this.cpuPast1h,
    required this.gpuLoadPast1h,
    required this.gpuMemPast1h,
    required this.score,
  });

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'trusted': trusted,
      'trust': trust,
      'trust_info': trustInfo,
      'is_supervisor': isSupervisor,
      'working': working,
      'recent': recent,
      'deployment': deployment,
      'version': version,
      'py_ver': pyVer,
      'last_remote_time': lastRemoteTime,
      'node_tz': nodeTz,
      'node_utc': nodeUtc,
      'main_loop_avg_time': mainLoopAvgTime,
      'main_loop_freq': mainLoopFreq,
      'uptime': uptime,
      'last_seen_sec': lastSeenSec,
      'avail_disk': availDisk,
      'avail_mem': availMem,
      'cpu_past1h': cpuPast1h,
      'gpu_load_past1h': gpuLoadPast1h,
      'gpu_mem_past1h': gpuMemPast1h,
      'SCORE': score,
    };
  }

  factory NetmonBoxDetails.fromMap(Map<String, dynamic> map) {
    return NetmonBoxDetails(
      address: map['address'] as String,
      trusted: map['trusted'] as bool,
      trust: (map['trust'] as num).toDouble(),
      trustInfo: map['trust_info'] as String,
      isSupervisor: map['is_supervisor'] as bool,
      working: map['working'] as String,
      recent: map['recent'] as bool,
      deployment: map['deployment'] as String,
      version: map['version'] as String,
      pyVer: map['py_ver'] as String,
      lastRemoteTime: map['last_remote_time'] as String,
      nodeTz: map['node_tz'] as String,
      nodeUtc: map['node_utc'] as String,
      mainLoopAvgTime: (map['main_loop_avg_time'] as num).toDouble(),
      mainLoopFreq: (map['main_loop_freq'] as num).toDouble(),
      uptime: map['uptime'] as String,
      lastSeenSec: (map['last_seen_sec'] as num).toDouble(),
      availDisk: (map['avail_disk'] as num).toDouble(),
      availMem: (map['avail_mem'] as num).toDouble(),
      cpuPast1h: (map['cpu_past1h'] as num?)?.toDouble() ??
          NetmonBoxDetails.invalidDoubleValue,
      gpuLoadPast1h:
          (map['gpu_load_past1h'] as num?)?.toDouble() ?? invalidDoubleValue,
      gpuMemPast1h:
          (map['gpu_mem_past1h'] as num?)?.toDouble() ?? invalidDoubleValue,
      score: (map['SCORE'] as num).toDouble(),
    );
  }

  static List<NetmonBoxDetails> fromList(dynamic jsonList) {
    final elements = <NetmonBoxDetails>[];
    try {
      final list = jsonList as List;
      for (final dynamic element in list) {
        elements.add(NetmonBoxDetails.fromMap(element as Map<String, dynamic>));
      }
    } catch (_) {
      if (kDebugMode) {
        print('Cannot decompile Netmon details');
      }
    }
    return elements;
  }

  static List<Map<String, dynamic>> toListMap(List<NetmonBoxDetails> list) {
    final elements = <Map<String, dynamic>>[];
    for (final NetmonBoxDetails element in list) {
      elements.add(element.toMap());
    }
    return elements;
  }
}
