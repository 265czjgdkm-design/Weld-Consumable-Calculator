import 'package:http/http.dart' as http;

/// POSTs to an Apps Script Web App and returns the response body's
/// [http.Response].
///
/// A Web App answers a POST with a 302 to script.googleusercontent.com whose
/// GET returns the real JSON. Browsers follow that automatically, but
/// dart:io (iOS/Android) does not follow redirects on POST, so the 302 has
/// to be followed by hand -- otherwise the server runs the action yet the
/// app sees an empty/HTML redirect body and reports failure.
Future<http.Response> appsScriptPost(
  Uri uri, {
  required String body,
  http.Client? client,
  Duration timeout = const Duration(seconds: 20),
}) async {
  final post = client?.post ?? http.post;
  final get = client?.get ?? http.get;
  final response = await post(uri, body: body).timeout(timeout);
  if (const {301, 302, 303}.contains(response.statusCode)) {
    final location = response.headers['location'];
    if (location == null) {
      throw const FormatException('Redirect without a Location header.');
    }
    return get(uri.resolve(location)).timeout(timeout);
  }
  return response;
}
