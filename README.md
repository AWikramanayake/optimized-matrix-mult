# optimized-matrix-mult
Optimizing matrix multiplication using parallelism and SIMD (AVX2, CUDA)
</br>
## Sections:
1. Optimizing matrix multiplication algorithm for spatial and temporal locality
2. Optimized AVX2: optimization with SIMD operations and pipelining
3. Parallelism: Multithreading with OpenMP, GPU computing with CUDA

## Background:
With its high degree of parallelizability and heavy yet formulaic memory access requirements, [matrix multiplication](https://en.wikipedia.org/wiki/Matrix_multiplication) is a highly optimizable task. Here, we explore various ways to improve the performance of a straightforward matrix multiplication operation A * B = C with square matrices of growing size stored in row-major order.

## Section 1: Optimizing for Spatial and Temporal Locality

When fetching an element of a matrix, CPUs load a chunk of data onto a cache line, assuming the importance of ***spatially local*** data (i.e. nearby chunks of data will also be important). For matrix A, this turns out to be true. We do indeed use the elements of a row, which are stored adjacently in memory. However, for matrix B, we need to use the elements of a column, which are spaced n elements apart (n = size of a row). If the entirety of matrix B fits on the cache line, this isn't an issue. However, if the matrix is too large, this causes a "miss" and the element has to be fetched from a higher rung of memory (L2/L3 cache or DRAM). Since each increasing memory tier has a much higher latency than the last, these memory "misses" should be avoided at all costs.
</br></br>
One simple way to address this would be to initialize matrix B in column-major order; if we need to access B column-by-column, why not store column elements contiguously so they get loaded together on the cache line? Indeed, this does work, but it is a band-aid solution. Recall that with matrix multiplication, in general, A\*B != B\*A. So if we later wanted to perform some other operation like B*C, we would need to recreate B in row-major order and C in column-major order to keep reaping the optimization benefits. These operations are not quick by any means. Instead, a storage-order-agnostic solution is to reorder the loops so operations that use adjacent elements are performed together: the "ikj" implementation.
</br></br>

<p align="center">
<img src="https://github.com/AWikramanayake/optimized-matrix-mult/blob/main/misc/NaiveVsIKJ.jpg?raw=true" width="720"/>
</p>
<p align="center">
Image 1: Naive and ikj implementations</br></br>

<p align="center">
<img src="https://github.com/AWikramanayake/optimized-matrix-mult/blob/main/misc/GFLOPSvsMatSize.jpg?raw=true" width="720"/>
</p>
<p align="center">
Figure 1: GFLOPS vs Matrix Size for each implementation</br> Vertical lines indicate points where matrices A, B, and C combined no longer fit in the L1/L2/L3 cache.</br>

The reordered loops help... to an extent. By reordering the loop iterators, we group operations that use elements of A and B row-by-row together. Unlike the naive implementation whose performance drops off a cliff the moment the first cache is exceeded, the ikj implementation maintains consistent performance until the matrices spill out of the cache, causing very expensive stalls. We can confirm this using hardware counters via Intel's VTune profiler.

<p align="center">
<img src="https://github.com/AWikramanayake/optimized-matrix-mult/blob/main/misc/1000mat_cachetest.jpg?raw=true" width="900"/>
</p>
<p align="center">
Figure 2: GFLOPS and misses/stalls for each implementation with 1000x1000 matrices</br>
Note: Misses & Stalls use the right y-axes</br></br>

<p align="center">
<img src="https://github.com/AWikramanayake/optimized-matrix-mult/blob/main/misc/1600mat_cachetest.jpg?raw=true" width="900"/>
</p>
<p align="center">
Figure 3: GFLOPS and misses/stalls for each implementation with 1600x1600 matrices</br>
Note: Misses & Stalls once again use the right y-axes. Also note y-axis for stalls is ~1e10, compared to 1e8 in Figure 2</br></br>

Until the L3 cache boundary (the last vertical line in Figure 1), the ikj implementation had minimal activity stalls. But in the rightmost region with very large matrices, we see that the ikj method's performance degrades at a similar rate to the naive method. Looking at our results with the VTune profiler, we see this is largely due to stalls from L3 misses. **NOTE:** the y-axis for stalls with 1000x1000 matrices is 1e8, and for 1600x1600 matrices it is 1e10. This means we see a **~80x increase** in stalled CPU cycles when we go from 1000x1000 matrices to 1600x1600 matrices.
</br></br>
Given how large matrices in real-world applications tend to be, we need to improve the implementation further. This time, we factor in the principle of ***temporal locality*** (i.e. the assumption that data accessed once will likely be required again) in addition to spatial locality. Once an element is accessed, it is usually cached with the expectation that it will be needed again. We once again re-order the operations of the matrix multiplication, but this time we perform operations that use elements from predefined blocks or tiles of each matrix. This way, we can limit ourselves to reusing cached elements regardless of how large the matrices are.
</br></br>
<p align="center">
<img src="https://github.com/AWikramanayake/optimized-matrix-mult/blob/main/misc/blocked_mmult.jpg?raw=true" width="900"/>
</p>
<p align="center">
Image 2: tiled implementation</br>

Note: BLOCKSIZE is a text macro that inserts the blocksize where necessary.</br> A text macro is used instead of a variable so that the insertion is done at compile time instead of adding more operations at runtime.
Using a blocksize of 32, we can limit ourselves to using 32x32 regions of each matrix, which fit into the L1 cache. From Figure 1, we see that the tiled implementation maintains its speed as we go past the L3 cache threshold. Looking at Figures 2 and 3, we see that the growth in expensive L3 misses and associated stalls is minuscule as we go from 1000x1000 matrices to 1600x1600 matrices, where the ikj implementation saw an ~80x increase in wasted cycles (again, notice that the y-axes for stalls are scaled to 1e8 in figure 2 and 1e10 in figure 3).
</br>

## Section 2: SIMD with AVX2

The Intel 12500h in my laptop supports AVX2 instructions including 256-bit vector operations, allowing us to work with 4 64-bit floats simultaneously (i.e. Single Instruction/Multiple Data, or SIMD). In theory, SIMD operations with 4 floats simultaneously could give us close to 4x the performance in an ideal case. Unfortunately, the GCC compiler doesn't employ these instructions automatically, but it can be nudged to use them using AVX2 intrinsic.

<p align="center">
<img src="https://github.com/AWikramanayake/optimized-matrix-mult/blob/main/misc/avx2.jpg?raw=true" width="720"/>
</p>
<p align="center">
Image 3: AVX2 matrix multiplication code with cleanup</br>

The minor caveat with using 256-bit vectors is that the load/store operations will go out of bounds if the number of rows/columns is not divisible by 4. To ensure that the algorithm works with matrices of arbitrary size, we need to employ cleanup code to handle the operations that might step out of bounds, using a mask when loading/storing to prevent seg faults. Using partially filled vectors means the maximum potential speedup is less than the ideal 4x, but the number of affected operations grows more slowly than the total number of operations and the initial overhead takes constant time.
</br></br>
So, how does the AVX2 implementation perform?

<p align="center">
<img src="https://github.com/AWikramanayake/optimized-matrix-mult/blob/main/misc/GFLOPSvsMatSizeAvx2.png?raw=true" width="720"/>
</p>
<p align="center">
Figure 4: AVX2 implementation performance compared to other implementations</br>

The zig-zagging at the tail end of the AVX2 graph is due to alternating between matrix sizes that are divisible by 4 or not (i.e. they incur the cleanup code penalty or do not). When cleanup code is not required, we see ~3.3x the performance of the basic tiled implementation. When cleanup code is needed, that drops to a still-impressive ~2.85x boost.
</br></br>
But we can go even further. The vector arithmetic instructions have a latency that should allow multiple iterations of the loop to be pipelined. However, due to the reusing of names (and thus registers in the CPU), an ordering is forced on the operations even though there is no data dependence. This is called a *name dependency* or an *antidependency* and can be mitigated using **loop unrolling**. We partially expand the loop by creating multiple copies of the arithmetic operation so that there is no longer any name dependency.

<p align="center">
<img src="https://github.com/AWikramanayake/optimized-matrix-mult/blob/main/misc/avx2unrolled.png?raw=true" width="720"/>
</p>
<p align="center">
Image 4: AVX2 unrolled matrix multiplication code with cleanup</br>

NOTE: like BLOCKSIZE above, UNROLL is a text macro that inserts the number of copies to make (i.e. the number of iterations to unroll).</br>
Additional complexity means more complex cleanup code. This code allows any matrix size (no divisibility requirements) but assumes the self-imposed rule that BLOCKSIZE > UNROLL*4 (specifically, I used BLOCKSIZE = 32, UNROLL = 4). Eliminating this rule would make the already long cleanup code even more unwieldy.
</br>
So, what does this code achieve? The GCC compiler with -O3 flags is able to pipeline the vector instructions efficiently. Without getting into an actual analysis of assembly code, just look at the density of vector instructions (the ones starting with the letter v) in L54 (basic) vs L94 (unrolled) below:

<p align="center">
<img src="https://github.com/AWikramanayake/optimized-matrix-mult/blob/main/misc/avx2assembly.jpg?raw=true" width="540"/>
</p>
<p align="center">
Image 5: AVX2 vs AVX unrolled assembly</br>

A cursory glance tells us that the number of efficient vector instructions for a given amount of overhead is much greater with the unrolled code. And what does this increase net us performance-wise?

<p align="center">
<img src="https://github.com/AWikramanayake/optimized-matrix-mult/blob/main/misc/GFLOPSvsMatSizeAvx2unrolled.png?raw=true" width="720"/>
</p>
<p align="center">
Figure 5: AVX2 unrolled performance vs other implementations</br>

Again, we see zig-zagging based on whether or not the cleanup code is triggered. Overall we have ~double the performance of the non-unrolled AVX2 implementation, and 5-6x the performance of the basic tiled implementation. This means for a 1600x1600 matrix, we have 30x the performance of the most basic naive implementation, without even using multithreading!
