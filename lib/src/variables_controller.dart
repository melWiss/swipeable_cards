import 'dart:async';

class Variables {
  /// the x position of the front card.
  final double frontCardXPosition;

  /// the value of this variable is either 0 or 200.
  final int durationInMilliSeconds;

  /// the value of the coefficient of the card to scale and translate accordingly
  /// it should be 0.0 or 1.0;
  final double animationCoeffiecient;
  Variables({
    required this.frontCardXPosition,
    required this.durationInMilliSeconds,
    required this.animationCoeffiecient,
  });

  Variables copyWith({
    double? frontCardXPosition,
    int? durationInMilliSeconds,
    double? animationCoeffiecient,
  }) {
    return Variables(
      frontCardXPosition: frontCardXPosition ?? this.frontCardXPosition,
      durationInMilliSeconds:
          durationInMilliSeconds ?? this.durationInMilliSeconds,
      animationCoeffiecient:
          animationCoeffiecient ?? this.animationCoeffiecient,
    );
  }

  @override
  String toString() {
    return 'Variables(frontCardXPosition: $frontCardXPosition, durationInMilliSeconds: $durationInMilliSeconds, animationCoeffiecient: $animationCoeffiecient)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Variables &&
        other.frontCardXPosition == frontCardXPosition &&
        other.durationInMilliSeconds == durationInMilliSeconds &&
        other.animationCoeffiecient == animationCoeffiecient;
  }

  @override
  int get hashCode {
    return frontCardXPosition.hashCode ^
        durationInMilliSeconds.hashCode ^
        animationCoeffiecient.hashCode;
  }
}

class VariablesController {
  Variables _variables = Variables(
    frontCardXPosition: 0,
    durationInMilliSeconds: 0,
    animationCoeffiecient: 0,
  );

  VariablesController() {
    _streamController.add(_variables);
  }

  late final StreamController<Variables> _streamController =
      StreamController<Variables>();

  Stream<Variables> get stream => _streamController.stream;

  /// get the current data
  Variables get variables => _variables;

  void updateVariables({
    double? frontCardXPosition,
    int? durationInMilliSeconds,
    double? animationCoeffiecient,
  }) {
    _variables = _variables.copyWith(
      frontCardXPosition: frontCardXPosition,
      durationInMilliSeconds: durationInMilliSeconds,
      animationCoeffiecient: animationCoeffiecient,
    );
    _streamController.add(_variables);
  }
}
