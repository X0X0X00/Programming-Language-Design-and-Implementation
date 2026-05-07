# CSC 254 — Assignment 4: Parallel N-body Simulation

Java parallelization assignment: an n² N-body gravity simulation, parallelized
two ways. Builds on the sequential `Nbody.java` baseline (Michael L. Scott,
2025), adding parallel implementations and load-balancing optimizations.

## Files
- `Nbody.java` — sequential baseline (provided)
- `NbodyThreads.java` — `Thread` + `CyclicBarrier` parallel version with
  remainder-aware load balancing and cached position reads
- `NbodyExecutor.java` — `ExecutorService` version with a pre-allocated task
  pool and a `TASKS_PER_THREAD = 4` over-decomposition for better balancing
- `CSC254_A4 - Sheet1.pdf` — assignment specification
- `README.pdf` — original course-supplied README

## Build & Run
```bash
javac Nbody.java NbodyThreads.java NbodyExecutor.java

# Sequential
java Nbody

# Threads with CyclicBarrier
java NbodyThreads

# Executor pool
java NbodyExecutor
```

## Tech Stack
Java (`javax.swing`, `java.util.concurrent.CyclicBarrier`,
`java.util.concurrent.ExecutorService`)
