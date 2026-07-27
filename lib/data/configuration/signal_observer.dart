import 'package:logger/logger.dart';
import 'package:nakama/nakama.dart';
import 'package:signals_core/signals_core.dart';

/// A custom observer that intercepts and logs changes to signals and computeds.
///
/// It formats signal values to print readable representations, especially for lists of [Camp] models.
class SignalObserver implements SignalsObserver {
  final Logger _logger;

  SignalObserver(this._logger);

  @override
  void onEffectCreated(Effect effect) {
    _logger.d('effect created: [${effect.globalId}|${effect.name}]');
  }

  @override
  void onEffectCalled(Effect effect) {
    _logger.d('effect called: [${effect.globalId}|${effect.name}]');
  }

  @override
  void onEffectRemoved(Effect instance) {
    _logger.d('effect removed: [${instance.globalId}|${instance.name}]');
  }

  @override
  void onComputedCreated<T>(Computed<T> instance) {
    _logger.d('computed created: [${instance.globalId}|${instance.name}]');
  }

  // Logs updates to computed values
  @override
  void onComputedUpdated<T>(Computed<T> instance, T value) {
    _logger.d(
      'computed updated: [${instance.globalId}|${instance.name}] => ${_formatValue(value)}',
    );
  }

  // Logs signal initialization
  @override
  void onSignalCreated<T>(Signal<T> instance, T value) {
    _logger.d(
      'signal created: [${instance.globalId}|${instance.name}] => ${_formatValue(value)}',
    );
  }

  // Logs signal updates
  @override
  void onSignalUpdated<T>(Signal<T> instance, T value) {
    _logger.d(
      'signal updated: [${instance.globalId}|${instance.name}] => ${_formatValue(value)}',
    );
  }

  /// Parses the signal state and formats AsyncState states accordingly.
  String _formatValue(dynamic value) {
    if (value is AsyncState) {
      if (value.isLoading) return 'AsyncLoading';
      if (value.hasError) return 'AsyncError(${value.error})';
      if (value.hasValue) {
        final data = value.value;
        return 'AsyncData(${_formatDataValue(data)})';
      }
    }

    if (value is Future) {
      return 'Future(${_formatDataValue(value)})';
    }
    return _formatDataValue(value);
  }

  /// Recursively formats list values or returns the formatted string of a single value.
  String _formatDataValue(dynamic data) {
    if (data is List) {
      return '[${data.map(_formatSingleValue).join(', ')}]';
    }
    return _formatSingleValue(data);
  }

  /// Unwraps the element value and extracts the camp name if the element is a [Camp].
  String _formatSingleValue(dynamic item) {
    if (item is Account) {
      return 'uid:${item.user.id}';
    }

    return item.toString();
  }
}
