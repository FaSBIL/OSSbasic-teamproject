import 'dart:io';
import 'dart:convert'; // LineSplitter, utf8 등에 필요

void main(List<String> args) async {
  const lcovPath = 'coverage/lcov.info';
  final lcovFile = File(lcovPath);

  if (!lcovFile.existsSync()) {
    stderr.writeln(
      '❌  $lcovPath 가 없습니다. 먼저 '
      '`flutter test --coverage` 등을 실행해 주세요.',
    );
    exit(1);
  }

  // ---------- lcov 파싱 ----------
  final Map<String, _FileStat> stats = {}; // path  →  통계
  String? currentPath;

  await for (final line in lcovFile
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter())) {
    if (line.startsWith('SF:')) {
      final path = line.substring(3); // 확실히 non-null
      stats[path] = _FileStat(); // 🅱 Map 키는 String
      currentPath = path;
    } else if (line.startsWith('LF:') && currentPath != null) {
      stats[currentPath]!.found = int.parse(line.substring(3));
    } else if (line.startsWith('LH:') && currentPath != null) {
      stats[currentPath]!.hit = int.parse(line.substring(3));
    }
  }

  // ---------- TOTAL 계산 ----------
  var totalFound = 0, totalHit = 0;
  for (final s in stats.values) {
    totalFound += s.found;
    totalHit += s.hit;
  }

  // ---------- 표 출력 ----------
  const nameWidth = 60;
  String pad(String s, int w, [bool right = false]) =>
      right ? s.padLeft(w) : s.padRight(w);

  stdout.writeln(
    '${pad("Name", nameWidth)}│${pad("Stmts", 7, true)}│'
    '${pad("Miss", 6, true)}│${pad("Cover", 6, true)}',
  );
  stdout.writeln('─' * (nameWidth + 23));

  final entries =
      stats.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

  for (final e in entries) {
    final fileName = e.key.replaceAll('\\', '/').split('/').last;
    final miss = e.value.found - e.value.hit;
    final pctStr = '${_pct(e.value.hit, e.value.found)}%';

    stdout.writeln(
      '${pad(fileName, nameWidth)}│${pad("${e.value.found}", 7, true)}│'
      '${pad("$miss", 6, true)}│${pad(pctStr, 6, true)}',
    );
  }

  stdout.writeln('─' * (nameWidth + 23));
  final missTotal = totalFound - totalHit;
  stdout.writeln(
    '${pad("TOTAL", nameWidth)}│${pad("$totalFound", 7, true)}│'
    '${pad("$missTotal", 6, true)}│'
    '${pad("${_pct(totalHit, totalFound)}%", 6, true)}',
  );
}

/// 파일별 라인 통계
class _FileStat {
  int found = 0; // 총 라인 수
  int hit = 0; // 커버된 라인 수
}

/// 퍼센트(정수) 계산
String _pct(int hit, int found) =>
    found == 0 ? '0' : (hit / found * 100).toStringAsFixed(0);
