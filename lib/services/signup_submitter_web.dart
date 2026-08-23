import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'signup_config.dart';

/// Web submission path: Google's form-response endpoint doesn't send CORS
/// headers, so a JS `fetch`/XHR POST gets its result blocked by the browser
/// even when the submission itself lands. A classic hidden `<form>` POST
/// into a hidden iframe sidesteps that entirely -- browsers have always
/// allowed cross-origin form posts; we just can't read the response, so we
/// treat the iframe's `load` event as "submitted".
Future<bool> submitSignupEmail(String email) async {
  final frameName = 'signup_frame_${DateTime.now().microsecondsSinceEpoch}';

  final iframe = web.HTMLIFrameElement()
    ..name = frameName
    ..style.display = 'none';

  void cleanUp() => iframe.remove();

  // The iframe must finish its own initial navigation (about:blank) and
  // register `frameName` as a browsing context *before* the form submits
  // targeting it -- otherwise the browser can't resolve that target yet and
  // opens a brand-new tab instead of posting into the hidden iframe.
  final ready = Completer<void>();
  late final JSFunction onReady;
  onReady = (web.Event _) {
    iframe.removeEventListener('load', onReady);
    if (!ready.isCompleted) ready.complete();
  }.toJS;
  iframe.addEventListener('load', onReady);
  web.document.body?.append(iframe);
  await ready.future.timeout(const Duration(seconds: 3), onTimeout: () {});

  final form = web.HTMLFormElement()
    ..method = 'POST'
    ..action = SignupConfig.formResponseUrl
    ..target = frameName
    ..style.display = 'none';
  final input = web.HTMLInputElement()
    ..type = 'hidden'
    ..name = SignupConfig.emailEntryField
    ..value = email;
  form.append(input);

  final completer = Completer<bool>();
  final timer = Timer(const Duration(seconds: 8), () {
    if (!completer.isCompleted) completer.complete(false);
    cleanUp();
    form.remove();
  });

  iframe.addEventListener(
    'load',
    (web.Event _) {
      timer.cancel();
      if (!completer.isCompleted) completer.complete(true);
      cleanUp();
      form.remove();
    }.toJS,
  );

  web.document.body?.append(form);
  form.submit();

  return completer.future;
}
