class VesniczeModel<T> {
  final T _defaultPopulation;

  VesniczeModel(this._defaultPopulation);

  List<_Entry<T>> _populations = [];

  _Entry _current;

  void addPopulation(T population, int size) {
    _populations.add(_Entry(population, size));
  }

  T take() {
    if (_current == null) return _defaultPopulation;
    if (_current._size == 0) {
      _current = null;
      return _defaultPopulation;
    } else {
      _current._size = _current._size - 1;
      T result = _current._value;
      if (_current._size == 0) {
        _current = null;
      }
      return result;
    }
  }

  void next() {
    if (_current != null && _current._size > 0) {
      // we can still take from here
      return;
    }
    if (_populations.isEmpty) {
      // we are done
      return;
    }
    _current = _populations.removeAt(0);
  }
}

class _Entry<T> {
  T _value;
  int _size;

  _Entry(this._value, this._size);
}
