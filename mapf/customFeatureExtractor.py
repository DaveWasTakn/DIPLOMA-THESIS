from typing import List, Tuple


def extractFeatures(instance: str) -> List[float]:
    from clingo.ast import Transformer, AST, ASTType, parse_files
    from collections import defaultdict
    from itertools import combinations

    class AstVisitor(Transformer):
        def __init__(self):
            self.symbolicAtoms = defaultdict(lambda: [])

        @staticmethod
        def getAllArgs(ast: AST) -> Tuple[float, ...]:
            if (args := ast.symbol.arguments) and args[0].ast_type == ASTType.Interval:
                return float(args[0].left.symbol.number), float(args[0].right.symbol.number)
            return tuple(float(s) if (s := str(arg.symbol)).isnumeric() else s for arg in args)

        def visit_SymbolicAtom(self, ast: AST) -> AST:
            self.symbolicAtoms[ast.symbol.name].append(self.getAllArgs(ast))
            return ast

    visitor = AstVisitor()
    parse_files([instance], lambda stm: visitor(stm))

    agents = visitor.symbolicAtoms["agent"][0][1]
    rangeX = visitor.symbolicAtoms["rangeX"][0][1]
    rangeY = visitor.symbolicAtoms["rangeY"][0][1]
    time = visitor.symbolicAtoms["time"][0][1]
    obstacles = len(visitor.symbolicAtoms["obstacle"])

    starts = {a: (x, y) for a, x, y, _ in visitor.symbolicAtoms["at"]}
    goals = {a: (x, y) for a, x, y in visitor.symbolicAtoms["goal"]}

    manhattanDistances = [abs(starts[agent][0] - goals[agent][0]) + abs(starts[agent][1] - goals[agent][1]) for agent in starts.keys()]

    ######### Line Segment Intersection Algorithm source: https://bryceboe.com/2006/10/23/line-segment-intersection-algorithm/
    def ccw(A, B, C):
        return (C[1] - A[1]) * (B[0] - A[0]) > (B[1] - A[1]) * (C[0] - A[0])

    def intersect(A, B, C, D):
        return ccw(A, C, D) != ccw(B, C, D) and ccw(A, B, C) != ccw(A, B, D)

    intersections = sum(
        1 for (a1, b1), (a2, b2) in combinations([(starts[a], goals[a]) for a in starts.keys()], 2)
        if intersect(a1, b1, a2, b2)
    )

    return [agents / (rangeX * rangeY), rangeX * rangeY, intersections / agents, sum(manhattanDistances), sum(manhattanDistances) / len(manhattanDistances)]
