import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brutewing/models/member.dart';
import 'package:brutewing/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('StorageService persistent CRUD unit test', () async {
    final members = await StorageService.getMembers();
    expect(members.length, equals(6));

    final newMember = Member(
      id: 99,
      name: 'Test Member',
      phone: '1234567890',
      plan: 'Monthly',
      start: DateTime(2026, 6, 1),
      end: DateTime(2026, 7, 1),
    );

    final updatedList = [newMember, ...members];
    await StorageService.saveMembers(updatedList);

    final reloaded = await StorageService.getMembers();
    expect(reloaded.length, equals(7));
    expect(reloaded.first.name, equals('Test Member'));

    // Test deletion persistence
    final afterDelete = reloaded.where((m) => m.id != 99).toList();
    await StorageService.saveMembers(afterDelete);

    final finalReload = await StorageService.getMembers();
    expect(finalReload.length, equals(6));
    expect(finalReload.any((m) => m.id == 99), isFalse);
  });
}
