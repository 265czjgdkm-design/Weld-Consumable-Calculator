import 'package:flutter/widgets.dart';

import 'app_locale.dart';
import 'strings.dart';

/// Exposes the app-wide [AppLocale] down the widget tree. Widgets that call
/// [AppLocaleScope.of] rebuild automatically whenever the language changes.
class AppLocaleScope extends InheritedNotifier<AppLocale> {
  const AppLocaleScope({
    super.key,
    required AppLocale locale,
    required super.child,
  }) : super(notifier: locale);

  static AppLocale of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'No AppLocaleScope found in context');
    return scope!.notifier!;
  }

  static L10nStrings stringsOf(BuildContext context) =>
      stringsFor(of(context).language);
}
