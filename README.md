# Path-Sensitive Pretenuring

End-to-end experimental pipeline for **path-sensitive pretenuring** in Pharo. The pipeline profiles a target application, builds a weighted allocation call graph from the profile, classifies its edges as long-lived or short-lived, traverses the graph under a chosen stopping strategy to extract *long-lived sender chains*, generates specialized compiled methods that pretenure allocations only along those chains, exports them to JSON, installs them into the application, and runs the rewritten variants under ReBench.

This is the implementation that produced the experimental results reported in Chapter “Path-Sensitive Pretenuring” of:

> Sebastian Jordan Montaño. *Memory Profiling in Dynamic Languages*. PhD thesis, Université de Lille / Inria, 2026.

## What the pipeline does

The pipeline is organized as five stages, applied per target application:

1. **Profiling.** The application is profiled with [FiLiP](https://github.com/jordanmontt/illimani-memory-profiler), the finalization-based object lifetime profiler. The profile contains, for each sampled allocation, the object lifetime, the object type, the object size, and the call stack that led to the allocation.

2. **Allocation graph construction.** A weighted directed allocation call graph is built from the profile. Nodes are methods reached during profiling. Edges represent message sends weighted by the objects allocated through them, including their sizes, lifetimes, and types.

3. **Edge classification.** Edges are pruned below a significance threshold and classified as *short-lived*, *long-lived*, or *immortal* using the [Pretenuring Advice Algorithm](https://github.com/jordanmontt/Pretenuring-Advice-Algorithm) of Blackburn et al. Because the Pharo VM has only two generations, the immortal category is merged into long-lived.

4. **Graph traversal and chain extraction.** The graph is traversed depth-first from the leaves (the primitive allocator methods) upward. A candidate *sender chain* must contain only long-lived edges and allocate objects of a single type. Three stopping strategies are supported:
   - **Application-Specific Methods** — stops at the first method that belongs to the application package.
   - **Caller of `new`** — stops at the first call site that directly invokes a higher-level allocator (e.g., `new`).
   - **Location of `new`** — stops at the higher-level allocator method itself (most conservative).

5. **Code rewriting.** The selected sender chains are *monomorphized* using the [Senders Chain Transformer](https://github.com/jordanmontt/senders-chain-transformer): each method along a chain is duplicated under a unique selector, and the leaf primitive allocator is replaced by a specialized version that pretenures. The original methods are left untouched, so all other callers continue to allocate in the young generation.

The generated specialized methods are **serialized to JSON** files (under `pretenuredMethods/`) so they can be reloaded into a fresh image without re-running the profiler. The pipeline can then **install** the methods on demand and **execute the benchmark** in the rewritten image.

## Repository layout

| Path | Contents |
| --- | --- |
| `src/` | Pharo source code: profiling driver, allocation-graph builder, classifier wiring, traversal strategies, JSON exporter, installer, and benchmark entry points. |
| `pretenuredMethods/` | Exported specialized compiled methods (JSON), one set per benchmark and per stopping strategy. These are the inputs to the install step. |
| `scripts/` | Shell scripts and ReBench configuration to run the benchmarks across configurations and collect results. |
| `.project` | Pharo project descriptor. |
| `LICENSE` | MIT. |

## Benchmarks

The pipeline is set up for the four benchmarks reported in the thesis:

- **Cormas** — agent-based simulation (ECEC model), 180,000 simulation steps.
- **DataFrame** — loading a 117 MB synthetic CSV with 1,000,000 rows × 6 columns.
- **HoneyGinger** — smoothed-particle hydrodynamics simulator, 600 rendering cycles.
- **Moose** — loading the SBSCL Java software model into the Moose meta-model.

For each benchmark, four variants are produced and benchmarked: the unmodified baseline plus the three stopping strategies.

## How to install

```smalltalk
EpMonitor disableDuring: [
    Metacello new
        baseline: 'PathSensitivePretenuring';
        repository: 'github://jordanmontt/path-sensitive-pretenuring:main';
        load ].
```

This loads the Pharo side of the pipeline and its dependencies (FiLiP, Illimani, the Pretenuring Advice Algorithm, the Senders Chain Transformer, and MethodProxies).

## Typical workflow

A full run for one benchmark looks like this:

1. **Profile.** Run the benchmark under FiLiP to obtain object lifetimes and call stacks.
2. **Generate.** Build the allocation graph, classify its edges, traverse it under each stopping strategy, and export the resulting specialized methods to JSON in `pretenuredMethods/`.
3. **Install.** In a fresh image, load the application and install the JSON-exported specialized methods for the chosen variant.
4. **Benchmark.** Run the benchmark in the rewritten image and record the execution time.

The expected output is a per-benchmark, per-strategy execution-time measurement that can be compared against the unmodified baseline.

## Running with ReBench

The `scripts/` directory contains a ReBench configuration that orchestrates the four benchmarks across the four configurations (baseline, Application-Specific, Caller of `new`, Location of `new`). The methodology follows the recommendations of Georges et al.: 30 iterations per benchmark, single VM invocation per iteration, geometric mean over normalized measurements, and a dedicated machine with non-essential OS services disabled.

A typical invocation is:

```bash
rebench scripts/<config-file>.conf
```

Refer to the configuration file for benchmark identifiers, image paths, and the output location for the resulting CSV.

## Reproducing the thesis results

The exported method sets in `pretenuredMethods/` correspond to the configurations evaluated in the thesis. To reproduce the reported numbers, install one variant at a time on top of the baseline image, run the corresponding benchmark under ReBench, and compare against the baseline run. The thesis reports speedups ranging from 1% to 11% across benchmarks, with an average improvement of 3.83%; results vary with the stopping strategy and the target application.

## Related projects

- [Illimani Memory Profiler](https://github.com/jordanmontt/illimani-memory-profiler) — the memory profiling framework providing FiLiP.
- [Senders Chain Transformer](https://github.com/jordanmontt/senders-chain-transformer) — the code-rewriting backend used in the rewriting step.
- [Pretenuring Advice Algorithm](https://github.com/jordanmontt/Pretenuring-Advice-Algorithm) — the GC-agnostic allocation-site classification algorithm.
- [MethodProxies](https://github.com/pharo-contributions/MethodProxies) — the underlying meta-safe instrumentation library used by FiLiP.
- [Veritas Benchmark Suite](https://github.com/jordanmontt/PharoVeritasBenchSuite) — the curated Pharo benchmark collection from which the experimental targets are drawn.

## License

MIT
