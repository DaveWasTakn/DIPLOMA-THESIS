from typing import List, Tuple


def extractFeatures(instance: str) -> List[float]:
    from clingo.ast import Transformer, AST, parse_files
    from collections import defaultdict

    class AstVisitor(Transformer):
        def __init__(self):
            self.symbolicAtoms = defaultdict(lambda: [])
            self.desiredAtomCounts = [
                "project",
                "job",
                "linked",
                "precedence",
                "mode",
            ]

        @staticmethod
        def getAllNumberArgs(ast: AST) -> Tuple[float, ...]:
            return tuple(float(arg.symbol.number) for arg in ast.symbol.arguments)

        def visit_SymbolicAtom(self, ast: AST) -> AST:
            self.symbolicAtoms[ast.symbol.name].append(self.getAllNumberArgs(ast))
            return ast

    def avgJobDurationToMaxMakespan(vis: AstVisitor) -> float:
        vals = []
        for j in vis.symbolicAtoms["job"]:
            job = j[0]
            modeAvailable = [x[1] for x in vis.symbolicAtoms["modeAvailable"] if x[0] == job]
            durationInMode = {x[1]: x[2] for x in vis.symbolicAtoms["durationInMode"] if x[0] == job and x[1] in modeAvailable}
            avgDuration = sum(durationInMode.values()) / len(modeAvailable)
            release = next(x[1] for x in vis.symbolicAtoms["release"] if x[0] == job)
            deadline = next(x[1] for x in vis.symbolicAtoms["deadline"] if x[0] == job)
            maxMakespan = deadline - release
            vals.append(avgDuration / maxMakespan)
        return sum(vals) / len(vals)

    def avgPenaltyRangeToMaxMakespan(vis: AstVisitor) -> float:
        vals = []
        for j in vis.symbolicAtoms["job"]:
            job = j[0]
            release = next(x[1] for x in vis.symbolicAtoms["release"] if x[0] == job)
            due = next(x[1] for x in vis.symbolicAtoms["due"] if x[0] == job)
            deadline = next(x[1] for x in vis.symbolicAtoms["deadline"] if x[0] == job)
            penaltyRange = deadline - due
            maxMakespan = deadline - release
            vals.append(penaltyRange / maxMakespan)
        return sum(vals) / len(vals)

    visitor = AstVisitor()
    parse_files([instance], lambda stm: visitor(stm))

    return [float(len(visitor.symbolicAtoms[name])) for name in visitor.desiredAtomCounts] \
        + [float(visitor.symbolicAtoms["horizon"][0][0])] \
        + [avgJobDurationToMaxMakespan(visitor)] \
        + [avgPenaltyRangeToMaxMakespan(visitor)]
