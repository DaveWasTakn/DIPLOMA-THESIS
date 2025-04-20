from typing import List


def extractFeatures(instance: str) -> List[float]:
    metaKeys = ["mstWeight", "convexHullArea", "meanDistances", "sdDistances"]
    metaInfo = {}

    with open(instance, "r") as f:
        for l in f.readlines():
            if all(k in metaInfo for k in metaKeys):
                break
            if l.startswith("%"):
                m = l[2:].strip("\n \r").split("=")
                metaInfo[m[0]] = float(m[1])

    return [metaInfo[k] for k in metaKeys]
