library(tspgen)
library(ggplot2)
library(splancs)
library(ape)

# monkey patch annoying and unnecessary checkmate assertions of tspgen:
unlockBinding("assertNumber", asNamespace("checkmate"))
assign("assertNumber", function(...) TRUE, envir = asNamespace("checkmate"))
lockBinding("assertNumber", asNamespace("checkmate"))

# adapted version of the build() method from tspgen, only applies a single Mutator
buildGraph <- function(vtx, type) {
  coords <- tspgen:::getUniformMatrix(n = vtx)
  if (type == 1) {
    return(applyMutator(coords, tspgen::doAxisProjectionMutation, pm = 0.7))
  } else if (type == 2) {
    return(applyMutator(coords, tspgen::doGridMutation, box.min = 0.8, box.max = 0.8))
  } else if (type == 3) {
    return(simpleCluster(coords, sd_spread = 0.05))
  } else {
    return(simple3Clusters(coords, sd_spread = 0.05, cluster_distance = 0.5))
  }
}

applyMutator <- function(coords, mutator, pm = 0.9, box.min = 1, box.max = 1) {
  coords <- do.call(mutator, list(coords = coords, pm = pm, box.min = box.min, box.max = box.max))
  attr(coords, "df") <- NULL
  coords <- tspgen:::forceToBounds(coords, bound.handling = "uniform")
  coords <- tspgen:::relocateDuplicates(coords)

  return(as.matrix(netgen::makeNetwork(coords * 1, lower = 0, upper = 1)[["coordinates"]], nrow = vtx))
}

simpleCluster <- function(coords, sd_spread = 0.05) {
  center <- runif(2)
  newCoords <- matrix(rnorm(length(coords), mean = rep(center, each = nrow(coords)), sd = sd_spread), ncol = 2)
  newCoords <- pmin(pmax(newCoords, 0), 1)
  return(newCoords)
}

simple3Clusters <- function(coords, sd_spread = 0.05, cluster_distance = 0.5) {
  num_points <- nrow(coords)
  points_per_cluster <- num_points %/% 3

  center1 <- runif(2, min = 0.25, max = 0.75)
  center2 <- pmin(pmax(center1 + c(cluster_distance, 0), 0), 1)
  center3 <- pmin(pmax(center1 + c(0, cluster_distance), 0), 1)

  cluster1 <- matrix(rnorm(points_per_cluster * 2, mean = rep(center1, each = points_per_cluster), sd = sd_spread), ncol = 2)
  cluster2 <- matrix(rnorm(points_per_cluster * 2, mean = rep(center2, each = points_per_cluster), sd = sd_spread), ncol = 2)
  cluster3 <- matrix(rnorm((num_points - 2 * points_per_cluster) * 2, mean = rep(center3, each = (num_points - 2 * points_per_cluster)), sd = sd_spread), ncol = 2)

  cluster1 <- pmin(pmax(cluster1, 0), 1)
  cluster2 <- pmin(pmax(cluster2, 0), 1)
  cluster3 <- pmin(pmax(cluster3, 0), 1)

  newCoords <- rbind(cluster1, cluster2, cluster3)
  return(newCoords)
}


addNoise <- function(graph, vtx, seed) {
  set.seed(seed)
  graph + matrix(rnorm(vtx * 2, sd = 0.025), nrow = vtx)
}

writeInstance <- function(graph, dists, vtx, edges, name) {
  fileConn <- file(name, open = "wt")
  meta <- paste(
    paste0("% vertices=", vtx),
    paste0("% convexHullPoints=", length(chull(graph))),
    paste0("% convexHullArea=", areapl(graph[chull(graph),])),
    paste0("% mstWeight=", sum(mst(dists) * dists)),
    paste0("% meanDistances=", mean(dists)),
    paste0("% sdDistances=", sd(dists)),
    "",
    sep = "\n"
  )
  writeLines(meta, fileConn)
  writeLines(paste0("edge(", edges[1,], ",", edges[2,], ")."), fileConn)
  writeLines(paste0("edgewt(", edges[1,], ",", edges[2,], ",", dists[t(edges)], ")."), fileConn)
  writeLines(paste0("edgewt(", edges[2,], ",", edges[1,], ",", dists[t(edges)], ")."), fileConn)
  writeLines(paste0("vtx(", 1:vtx, ")."), fileConn)
  close(fileConn)
}

for (vtx in c(40, 60, 80, 100)) {
  for (i in 1:4) {
    set.seed(42)
    graph <- buildGraph(vtx, i)
    for (j in 1:6) {
      instName <- paste0("tsp_", vtx, "_", i, "_", j)
      x <- addNoise(graph, vtx, j)
      png(paste0(instName, ".png"))
      plot(data.frame(x), xlim = c(0, 1), ylim = c(0, 1))
      dev.off()
      d <- as.matrix(ceiling(dist(x, diag = T, upper = T) * 100), nrow = vtx)
      edges <- combn(1:vtx, 2)[, sample(1:choose(vtx, 2), choose(vtx, 2) / 2)]
      writeInstance(graph, d, vtx, edges, paste0(instName, ".lp"))
    }
  }
}
