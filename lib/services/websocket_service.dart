import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import '../config/api_config.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  Timer? _pollingTimer;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  
  final Map<String, List<Function(Map<String, dynamic>)>> _listeners = {};

  // Connect to Reverb WebSocket
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final uri = Uri.parse(
        'ws://${ApiConfig.wsHost}:${ApiConfig.wsPort}/app/${_getAppKey()}?protocol=7&client=flutter&version=1.0.0'
      );
      
      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      _channel!.stream.listen(
        _handleMessage,
        onDone: () {
          _isConnected = false;
          _scheduleReconnect();
        },
        onError: (error) {
          _isConnected = false;
          _startPollingFallback();
        },
      );
    } catch (e) {
      _startPollingFallback();
    }
  }

  String _getAppKey() {
    return 'auctobid-app-key'; // Same as REVERB_APP_KEY
  }

  void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message.toString());
      final event = data['event'] as String?;
      final channel = data['channel'] as String?;
      
      if (event != null && channel != null) {
        final fullEventName = '$channel:$event';
        final payload = data['data'] != null 
            ? (data['data'] is String ? json.decode(data['data']) : data['data'])
            : {};
        
        _notifyListeners(fullEventName, payload);
      }
    } catch (e) {
      // Ignore parse errors
    }
  }

  // Subscribe to auction channel
  void subscribeToAuction(int auctionId) {
    if (_channel != null && _isConnected) {
      final subscribeMessage = json.encode({
        'event': 'pusher:subscribe',
        'data': {
          'channel': 'auction.$auctionId',
        },
      });
      _channel!.sink.add(subscribeMessage);
    }
  }

  // Unsubscribe from auction channel
  void unsubscribeFromAuction(int auctionId) {
    if (_channel != null && _isConnected) {
      final unsubscribeMessage = json.encode({
        'event': 'pusher:unsubscribe',
        'data': {
          'channel': 'auction.$auctionId',
        },
      });
      _channel!.sink.add(unsubscribeMessage);
    }
  }

  // Register listener for new bids
  void onNewBid(int auctionId, Function(Map<String, dynamic>) callback) {
    final eventName = 'auction.$auctionId:new-bid';
    _listeners.putIfAbsent(eventName, () => []);
    _listeners[eventName]!.add(callback);
  }

  // Register listener for auction closed
  void onAuctionClosed(int auctionId, Function(Map<String, dynamic>) callback) {
    final eventName = 'auction.$auctionId:auction-closed';
    _listeners.putIfAbsent(eventName, () => []);
    _listeners[eventName]!.add(callback);
  }

  // Remove listeners for auction
  void removeAuctionListeners(int auctionId) {
    _listeners.removeWhere((key, value) => key.startsWith('auction.$auctionId'));
  }

  void _notifyListeners(String eventName, Map<String, dynamic> data) {
    if (_listeners.containsKey(eventName)) {
      for (final callback in _listeners[eventName]!) {
        callback(data);
      }
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      connect();
    });
  }

  // Fallback polling when WebSocket is unavailable
  void _startPollingFallback() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      // Polling logic would refresh auction data here
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _pollingTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    _listeners.clear();
  }
}
