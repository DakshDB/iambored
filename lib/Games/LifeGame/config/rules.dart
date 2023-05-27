import '../models/rule.dart';

List<Rule> rules = [
  Rule(name: "Conway's Life B3/S23", value: "B3/S23", survival: [2, 3], birth: [3]),
  Rule(name: "HighLife B36/S23", value: "B36/S23", survival: [2, 3], birth: [3, 6]),
  Rule(name: "DryLife B37/S23", value: "B37/S23", survival: [2, 3], birth: [3, 7]),
  Rule(name: "34 Life B34/S34", value: "B34/S34", survival: [3, 4], birth: [3, 4]),
  Rule(name: "Replicator B1357/S1357", value: "B1357/S1357", survival: [1, 3, 5, 7], birth: [1, 3, 5, 7]),
  Rule(name: "Fredkin B1357/S02468", value: "B1357/S02468", survival: [0, 2, 4, 6, 8], birth: [1, 3, 5, 7]),
  Rule(name: "Seeds B2/S", value: "B2/S", survival: [], birth: [2]),
  Rule(name: "Live Free or Die B2/S0", value: "B2/S0", survival: [0], birth: [2]),
  Rule(name: "Flock B3/S12", value: "B3/S12", survival: [1, 2], birth: [3]),
  Rule(name: "Move B368/S245", value: "B368/S245", survival: [2, 4, 5], birth: [3, 6, 8]),
  Rule(name: "Day & Night B3678/34678", value: "B3678/34678", survival: [3, 4, 6, 7, 8], birth: [3, 4, 6, 7, 8]),
  Rule(name: "Pedestrian Life B38/S23", value: "B38/S23", survival: [2, 3], birth: [3, 8]),
  Rule(name: "2x2 B36/S125", value: "B36/S125", survival: [1, 2, 5], birth: [3, 6]),
  Rule(name: "Mazectric B3/S1234", value: "B3/S1234", survival: [1, 2, 3, 4], birth: [3]),
  Rule(name: "Maze B3/S12345", value: "B3/S12345", survival: [1, 2, 3, 4, 5], birth: [3]),
  Rule(name: "Life Without Death B3/S012345678", value: "B3/S012345678", survival: [0, 1, 2, 3, 4, 5, 6, 7, 8], birth: [3]),
];
