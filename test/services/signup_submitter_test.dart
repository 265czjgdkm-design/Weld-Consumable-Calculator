import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:weld_consumable_calculator/services/signup_config.dart';
import 'package:weld_consumable_calculator/services/signup_submitter.dart';

void main() {
  test('Form entry ids are wired', () {
    expect(SignupConfig.emailEntryField, 'entry.708179914');
    expect(SignupConfig.firstNameEntryField, 'entry.1576418057');
    expect(SignupConfig.localeEntryField, 'entry.1914024187');
  });

  Future<Map<String, String>> capture(Future<bool> Function() submit) async {
    late Map<String, String> body;
    final ok = await http.runWithClient(
      submit,
      () => MockClient((request) async {
        expect(request.url.toString(), SignupConfig.formResponseUrl);
        body = Uri.splitQueryString(request.body);
        return http.Response('', 200);
      }),
    );
    expect(ok, isTrue);
    return body;
  }

  test('posts email, first name and locale', () async {
    final body = await capture(
      () => submitSignupEmail('a@b.co', firstName: 'Ayşe', locale: 'tr'),
    );
    expect(body, {
      'entry.708179914': 'a@b.co',
      'entry.1576418057': 'Ayşe',
      'entry.1914024187': 'tr',
    });
  });

  test('omits fields that are not known', () async {
    final body = await capture(() => submitSignupEmail('a@b.co'));
    expect(body, {'entry.708179914': 'a@b.co'});
  });
}
