import "package:moxlib/automaton.dart";

import "package:test/test.dart";

enum States {
  a, b, c, trap
}

void main() {
  test("Test a simple DFA", () {
      final automaton = DeterministicFiniteAutomaton<States, int>(States.a);
      automaton.addTransition(States.a, 1, States.b);
      automaton.addTransition(States.b, 2, States.c);
      automaton.addTransition(States.c, 3, States.a);

      expect(automaton.state, States.a);
      automaton.onInput(1);
      expect(automaton.state, States.b);
      automaton.onInput(2);
      expect(automaton.state, States.c);
      automaton.onInput(3);
      expect(automaton.state, States.a);
  });

  test("Test a simple DFA with a trap state", () { 
      final automaton = DeterministicFiniteAutomaton<States, int>(States.a, trapState: States.trap);
      automaton.addTransition(States.a, 1, States.b);
      automaton.addTransition(States.b, 2, States.c);
      automaton.addTransition(States.c, 3, States.a);

      expect(automaton.state, States.a);
      automaton.onInput(1);
      expect(automaton.state, States.b);
      automaton.onInput(2);
      expect(automaton.state, States.c);
      automaton.onInput(4);
      expect(automaton.state, States.trap);

      // Transitioning away from the trap state should not be possible
      automaton.onInput(5);
      expect(automaton.state, States.trap);
  });

  test("Test a simple Mealy Automaton", () {
      bool called = false;
      final callback = (state, input) {
        called = true;
      };
      final automaton = MealyAutomaton<States, int>(States.a);

      automaton.addTransition(States.a, 1, States.b, callback);

      automaton.onInput(1);

      expect(automaton.state, States.b);
      expect(called, true);
  });

  test("Test a simple Mealy Automaton with a trap state", () {
      bool called = false;
      bool trapCalled = false;
      final callback = (state, input) {
        called = true;
      };
      final trapCallback = (state, input) {
        trapCalled = true;
      };
      final automaton = MealyAutomaton<States, int>(States.a, trapState: States.trap, trapCallback: trapCallback);

      automaton.addTransition(States.a, 1, States.b, callback);

      automaton.onInput(1);
      expect(called, true);

      automaton.onInput(1);
      expect(automaton.state, States.trap);
      expect(trapCalled, true);
  });
}
