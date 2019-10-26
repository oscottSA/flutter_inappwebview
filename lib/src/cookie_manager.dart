import 'package:flutter/services.dart';

///Manages the cookies used by WebView instances.
///
///**NOTE for iOS**: available from iOS 11.0+.
class CookieManager {
  static bool _initialized = false;
  static const MethodChannel _channel = const MethodChannel('com.pichillilorenzo/flutter_inappbrowser_cookiemanager');

  static void _init () {
    _channel.setMethodCallHandler(handleMethod);
    _initialized = true;
  }

  static Future<dynamic> handleMethod(MethodCall call) async {
  }

  ///Sets a cookie for the given [url]. Any existing cookie with the same [host], [path] and [name] will be replaced with the new cookie. The cookie being set will be ignored if it is expired.
  ///
  ///The default value of [path] is `"/"`.
  ///If [domain] is `null`, its default value will be the domain name of [url].
  static Future<void> setCookie(String url, String name, String value,
      { String domain,
        String path = "/",
        int expiresDate,
        int maxAge,
        bool isSecure }) async {
    if (!_initialized)
      _init();

    if (domain == null)
      domain = getDomainName(url);

    assert(url != null && url.isNotEmpty);
    assert(name != null && name.isNotEmpty);
    assert(value != null && value.isNotEmpty);
    assert(domain != null && domain.isNotEmpty);
    assert(path != null && path.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('name', () => name);
    args.putIfAbsent('value', () => value);
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    args.putIfAbsent('expiresDate', () => expiresDate?.toString());
    args.putIfAbsent('maxAge', () => maxAge);
    args.putIfAbsent('isSecure', () => isSecure);

    await _channel.invokeMethod('setCookie', args);
  }

  ///Gets all the cookies for the given [url].
  static Future<List<Map<String, dynamic>>> getCookies(String url) async {
    if (!_initialized)
      _init();

    assert(url != null && url.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    List<dynamic> cookies = await _channel.invokeMethod('getCookies', args);
    cookies = cookies.cast<Map<dynamic, dynamic>>();
    for(var i = 0; i < cookies.length; i++) {
      cookies[i] = cookies[i].cast<String, dynamic>();
    }
    cookies = cookies.cast<Map<String, dynamic>>();
    return cookies;
  }

  ///Gets a cookie by its [name] for the given [url].
  static Future<Map<String, dynamic>> getCookie(String url, String name) async {
    if (!_initialized)
      _init();

    assert(url != null && url.isNotEmpty);
    assert(name != null && name.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    List<dynamic> cookies = await _channel.invokeMethod('getCookies', args);
    cookies = cookies.cast<Map<dynamic, dynamic>>();
    for(var i = 0; i < cookies.length; i++) {
      cookies[i] = cookies[i].cast<String, dynamic>();
      if (cookies[i]["name"] == name)
        return cookies[i];
    }
    return null;
  }

  ///Removes a cookie by its [name] for the given [url], [domain] and [path].
  ///
  ///The default value of [path] is `"/"`.
  ///If [domain] is `null` or empty, its default value will be the domain name of [url].
  static Future<void> deleteCookie(String url, String name, {String domain = "", String path = "/"}) async {
    if (!_initialized)
      _init();

    if (domain == null || domain.isEmpty)
      domain = getDomainName(url);

    assert(url != null && url.isNotEmpty);
    assert(name != null && name.isNotEmpty);
    assert(domain != null && url.isNotEmpty);
    assert(path != null && url.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('name', () => name);
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    await _channel.invokeMethod('deleteCookie', args);
  }

  ///Removes all cookies for the given [url], [domain] and [path].
  ///
  ///The default value of [path] is `"/"`.
  ///If [domain] is `null` or empty, its default value will be the domain name of [url].
  static Future<void> deleteCookies(String url, {String domain = "", String path = "/"}) async {
    if (!_initialized)
      _init();

    if (domain == null || domain.isEmpty)
      domain = getDomainName(url);

    assert(url != null && url.isNotEmpty);
    assert(domain != null && url.isNotEmpty);
    assert(path != null && url.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    await _channel.invokeMethod('deleteCookies', args);
  }

  ///Removes all cookies.
  static Future<void> deleteAllCookies() async {
    if (!_initialized)
      _init();

    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('deleteAllCookies', args);
  }

  static String getDomainName(String url) {
    Uri uri = Uri.parse(url);
    String domain = uri.host;
    if (domain == null)
      return "";
    return domain.startsWith("www.") ? domain.substring(4) : domain;
  }
}