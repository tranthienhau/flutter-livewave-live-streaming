import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livewave/data/models.dart';
import 'package:livewave/state/providers.dart';

void main() {
  test('gift spend debits coins and refuses when balance is short', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(walletProvider.notifier);
    expect(c.read(walletProvider).coins, 1250);
    expect(n.spend(100, 'Sent Rocket'), isTrue);
    expect(c.read(walletProvider).coins, 1150);
    expect(n.spend(5000, 'Sent Wave x5'), isFalse);
    expect(c.read(walletProvider).coins, 1150);
    n.topUp(const CoinPack(500, r'$4.99'));
    expect(c.read(walletProvider).coins, 1650);
    expect(c.read(walletProvider).txns.first.title, 'Top up');
  });
}
