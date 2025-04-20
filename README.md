# Bayesian Hyperparameter Optimization with ALASPO and Applications

## Experimental Results
Experimental results are available at Zenodo https://doi.org/10.5281/zenodo.15252027

## Supplementary Materials
For each benchmark problem, we provide the used encoding, instances (separate for tuning and validation), instance generator (if used), and custom feature extractor.

### Sources
- Test Laboratory Scheduling Problem (TLSPS)
  - **encoding** [GMM21]
  - **instances** [MM18,MM21]
- Valves Location Problem (VLP)
  - **encoding** [GNP13]
  - **instances** ![ASPCOMP 2014](https://www.mat.unical.it/aspcomp2014)
- Travelling Salesman Problem (TSP)
  - **encoding** ![Asparagus Platform](https://asparagus.cs.uni-potsdam.de) [EGHR+22]
  - **instances** our [instance generator](./tsp/instanceGenerator.R) makes use of [tspgen](https://github.com/jakobbossek/tspgen)
- Multi-Agent Path Finding (MAPF)
  - **encoding** [GHB20]
  - **instances** our [instance generator](./mapf/instanceGenerator.py) generates instances modelled after [GHB20]


[GMM21] Tobias Geibinger, Florian Mischek, and Nysret Musliu. Constraint Logic
        Programming for Real-World Test Laboratory Scheduling. Proceedings of
        the AAAI Conference on Artificial Intelligence, 35(7):6358–6366, May 2021.

[MM18]  Florian Mischek and Nysret Musliu. The Test Laboratory Scheduling
        Problem. Technical Report CD-TR 2018/1, November 2018.

[MM21]  Florian Mischek and Nysret Musliu. A local search framework for industrial
        test laboratory scheduling. Annals of Operations Research, 302(2):533–562,
        2021.

[GNP13] M. Gavanelli, M. Nonato, and A. Peano. An asp approach for the valves
        positioning optimization in a water distribution system. Journal of Logic
        and Computation, 25(6):1351–1369, December 2013.

[EGHR+22] Thomas Eiter, Tobias Geibinger, Nelson Higuera Ruiz, Nysret Musliu,
          Johannes Oetsch, and Daria Stepanova. Large-neighbourhood search for
          optimisation in answer-set solving. Proceedings of the AAAI Conference
          on Artificial Intelligence, 36(5):5616–5625, June 2022.

[GHB20] Rodrigo N. Gómez, Carlos Hernández, and Jorge A. Baier. Solving sum-of-
        costs multi-agent pathfinding with answer-set programming. Proceedings
        of the AAAI Conference on Artificial Intelligence, 34(06):9867–9874, April
        2020.
