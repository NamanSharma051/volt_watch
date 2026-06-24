class KalmanFilter {
  final double _q; // Process noise covariance
  final double _r; // Measurement noise covariance
  double _x = 0.0; // Estimated value
  double _p = 1.0; // Estimation error covariance
  double _k = 0.0; // Kalman gain
  bool _initialized = false;

  KalmanFilter({double q = 0.02, double r = 1.5})
      : _q = q,
        _r = r;

  void reset() {
    _initialized = false;
  }

  double filter(double measurement) {
    if (!_initialized) {
      _x = measurement;
      _p = 1.0;
      _initialized = true;
      return _x;
    }

    // Prediction Update
    _p = _p + _q;

    // Measurement Update
    _k = _p / (_p + _r);
    _x = _x + _k * (measurement - _x);
    _p = (1.0 - _k) * _p;

    return _x;
  }
}
