class NoTransitionPossibleException implements Exception {
  @override
  String errMsg() => "The transition graph allows no transition";
}

/// A deterministic finite automaton. [T] is the state type while
/// [I] is the input type.
/// Edges of the node must be added with [addTransition]. If a trap state
/// is required, it can be set in the constructor.
class DeterministicFiniteAutomaton<T, I> {
  /// The current state of the DFA
  T _state;
  /// The edges of the DFA: State x Input -> State
  Map<T, Map<I, T>> _transitions;
  /// Trap state 
  T? trapState;

  /// The argument is the initial state
  DeterministicFiniteAutomaton(this._state, { this.trapState }) : _transitions = {};

  T get state => _state;

  void addTransition(T oldState, I input, T newState) {
    assert(oldState != trapState);
    // These are handled implicitly if no transition has been found
    assert(newState != trapState);

    if (!_transitions.containsKey(oldState)) {
      _transitions[oldState] = {};
    }

    _transitions[oldState]![input] = newState;
  }

  /// Transition the DFA based on its current state and the input [input].
  void onInput(I input) {
    final newState = _transitions[_state]?[input];
    if (newState == null) {
      // Go to the trap state if we can
      if (trapState != null) {
        _state = trapState!;
        return;
      } else {
        throw NoTransitionPossibleException();
      }
    }

    _state = newState;
  }

  /// Returns where [input] would take the automaton to. Returns null if no transition
  /// is possible, ignoring trap transitions.
  T? peekTransition(I input) {
    if (!_transitions.containsKey(_state) || !_transitions[_state]!.containsKey(input)) {
      return null;
    }

    return _transitions[_state]![input]!;
  }
}

typedef MealyAutomatonCallback<T, I> = void Function(T oldState, I input);
class MealyAutomaton<T, I> {
  /// The base automaton
  final DeterministicFiniteAutomaton<T, I> _automaton;
  /// Mapping of State x Input -> Output callback
  Map<T, Map<I, MealyAutomatonCallback<T, I>>> _outputs;
  /// Trap state
  MealyAutomatonCallback<T, I>? trapCallback;

  // TODO: Assert that trapState != null implies trapCallback != null.
  MealyAutomaton(T initialState, { T? trapState, this.trapCallback })
    : _outputs = {},
      _automaton = DeterministicFiniteAutomaton(initialState, trapState: trapState);

  T get state => _automaton.state;
      
  void addTransition(T oldState, I input, T newState, MealyAutomatonCallback<T, I> callback) {
    _automaton.addTransition(oldState, input, newState);

    if (!_outputs.containsKey(oldState)) {
      _outputs[oldState] = {};
    }

    _outputs[oldState]![input] = callback;
  }

  void onInput(I input) {
    final _state = _automaton.state;
    if (_automaton.peekTransition(input) == null && trapCallback == null) {
      throw new NoTransitionPossibleException();
    }

    final callback = _outputs[_state]?[input] ?? trapCallback!;

    _automaton.onInput(input);
    callback(_state, input);
  }
}
