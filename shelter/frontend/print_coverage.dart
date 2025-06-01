import 'dart:io';

void main(List<String> args) async {
  final lines = await File('coverage/lcov.info').readAsLines();
  var totalFound = 0, totalHit = 0;
  for (final l in lines) {
    if (l.startsWith('LF:')) totalFound += int.parse(l.substring(3));
    if (l.startsWith('LH:')) totalHit += int.parse(l.substring(3));
  }
  final pct = (totalHit / totalFound * 100).toStringAsFixed(2);
  print('Line coverage: $pct% ($totalHit of $totalFound)');
}
