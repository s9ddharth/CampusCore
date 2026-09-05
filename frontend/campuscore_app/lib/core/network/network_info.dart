import 'dart:io';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementation of NetworkInfo that checks connectivity 
/// by doing a simple DNS lookup.
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}