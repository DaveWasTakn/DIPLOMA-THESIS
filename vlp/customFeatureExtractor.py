from typing import List, Tuple


def extractFeatures(instance: str) -> List[float]:
    from clingo.ast import Transformer, AST, ASTType, parse_files
    from collections import defaultdict

    class AstVisitor(Transformer):
        def __init__(self):
            self.symbolicAtoms = defaultdict(lambda: [])

        @staticmethod
        def getAllNumberArgs(ast: AST) -> Tuple[float, ...]:
            if (args := ast.symbol.arguments) and args[0].ast_type == ASTType.Interval:
                return float(args[0].left.symbol.number), float(args[0].right.symbol.number)
            return tuple(float(arg.symbol.number) for arg in ast.symbol.arguments)

        def visit_SymbolicAtom(self, ast: AST) -> AST:
            self.symbolicAtoms[ast.symbol.name].append(self.getAllNumberArgs(ast))
            return ast

    visitor = AstVisitor()
    parse_files([instance], lambda stm: visitor(stm))

    valves = visitor.symbolicAtoms["valves_number"][0][0]
    valves_per_pipe = visitor.symbolicAtoms["valves_per_pipe"][0][0]
    junctions = len(visitor.symbolicAtoms["junction"])
    pipes = len(visitor.symbolicAtoms["pipe"])
    dems = [x[2] for x in visitor.symbolicAtoms["dem"]]

    return [valves/pipes, sum(dems)/len(dems), valves/sum(dems)]
