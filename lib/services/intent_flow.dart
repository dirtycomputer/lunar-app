import 'dart:math';
import 'bazi.dart';

enum AppIntent { chart, match, agent }

enum MatchReason { balance, support, shared, branches, contrast }

MatchReason matchReason(MatchResult match) {
  if (match.resonance >= 88 &&
      match.resonance >= match.balance &&
      match.resonance >= match.connection) {
    return MatchReason.branches;
  }
  if (match.connection >= 90) return MatchReason.support;
  if (match.balance >= 80) return MatchReason.balance;
  if (match.connection >= 80) return MatchReason.shared;
  return MatchReason.contrast;
}

class RandomMatchPicker {
  final Random random;
  String? _lastId;
  RandomMatchPicker({Random? random}) : random = random ?? Random();

  MatchResult? pick(List<MatchResult> eligible) {
    if (eligible.isEmpty) return null;
    final pool = eligible.length > 1
        ? eligible.where((m) => m.person.id != _lastId).toList()
        : eligible;
    final result = pool[random.nextInt(pool.length)];
    _lastId = result.person.id;
    return result;
  }
}
