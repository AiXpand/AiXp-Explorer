class E2DctStat {
  final String type;
  final String flow;
  final double idle;
  final num dps;
  final num cfgDps;
  final num tgtDps;
  final dynamic runStats;

  /// Int or String ??? :(
  final List<String>? collecting;
  final int fails;
  final String timeNow;

  E2DctStat({
    required this.type,
    required this.flow,
    required this.idle,
    required this.dps,
    required this.cfgDps,
    required this.tgtDps,
    required this.runStats,
    this.collecting,
    required this.fails,
    required this.timeNow,
  });

  Map<String, dynamic> toMap() {
    return {
      'TYPE': type,
      'FLOW': flow,
      'IDLE': idle,
      'DPS': dps,
      'CFG_DPS': cfgDps,
      'TGT_DPS': tgtDps,
      'RUNSTATS': runStats,
      'COLLECTING': collecting,
      'FAILS': fails,
      'NOW': timeNow,
    };
  }

  factory E2DctStat.fromMap(Map<String, dynamic> map) {
    final collectingBody = map['COLLECTING'];
    List<String>? collectingStats;
    if (collectingBody != null) {
      if (collectingBody == 'None') {
        collectingStats = null;
      } else {
        if (collectingBody.runtimeType is List) {
          collectingStats =
              (collectingBody as List).map((e) => e as String).toList();
        }
      }
    }

    return E2DctStat(
      type: map['TYPE'] as String,
      flow: map['FLOW'] as String,
      idle: map['IDLE'] as double,
      dps: map['DPS'] as num,
      cfgDps: map['CFG_DPS'] as num,
      tgtDps: map['TGT_DPS'] as num,
      runStats: map['RUNSTATS'],
      collecting: collectingStats,
      fails: map['FAILS'] as int,
      timeNow: map['NOW'] as String,
    );
  }
}
