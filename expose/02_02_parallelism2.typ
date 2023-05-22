#import "utils.typ": *

== Parallelism

For sequential algorithms, the notion of runtime is usually sufficient when trying to evaluate the time efficiency of an algorithm.
However, for parallel algorithms, this metric is insufficient in describing the parallel algorithm's efficiency.//, since now the actual time efficiency also depends on other values like the number of processors.
Since the goal of a parallel algorithm is to solve a problem more efficiently, we need metrics to quantify our improvements and evaluate the algorithm's performance. We will also get into what "more efficiently" exactly means.

First, we need a measure of the parallel algorithm's performance gain over the best sequential solution.

#definition(title: [Speedup @jaja_introduction_1992], [
Let $P$ be a problem with an input size of $n$ and  $P$ be solved by a sequential algorithm in $T^*(n)$ time, where $T^*(n)$ is the lower bound for any sequential solution of $P$. Then let $A$ be a parallel algorithm that solves $P$ with $p$ processors in $T_p(n)$ time. We call the speedup achieved by $A$ to be $ S_p(n) = (T^*(n)) / (T_p(n)). $
]) <def:speedup>

The meaning of speedup is intuitive. If $A$ requires half the time that the sequential algorithm required, then the corresponding speedup will be $2$.
Also, since $T^*(n)$ is not always known formally, it is common to use the complexity of the best known sequential algorithm @jaja_introduction_1992.

Once the speedup is determined, we might also want to know to what extent each of the $p$ processors is taken advantage of. This is captured in the #emph[efficiency] metric.

#definition(title: [Efficiency @jaja_introduction_1992], [
  The efficiency of parallel algorithm $A$ is defined as $ E_p(n) = (T_1(n)) / (p T_p(n)) $
]) <def:efficiency>

The intuitive understanding of efficiency is not to compare $A$'s advantage over sequential solutions like speedup does. Rather, $E_p(n)$ measures by what factor performance improves when executing $A$ with $p$ processors, over executing $A$ on a single core.
Ideally, we would have $E_p(n) = 1$, such that all processors are fully utilized.

In designing algorithms, we will be using the #emph[Work-Time] model, which offers a simple way to quantify the complexity of a parallel algorithm.

#definition(title: [Time @jaja_introduction_1992], [
  For a parallel algorithm, the time $T(n)$ is the minimum number of time steps an algorithm requires, regardless of how many processors are available.
  $T(n)$ can also be characterized as the limit of $T_p(n)$ as $p$ approaches infinity.
]) <def:time>

#definition(title: [Work @blelloch_parallel_1996], [
  For a parallel algorithm $A$, the work $W(n)$ performed by $A$ on an input of size $n$ is defined by the total amount of operations required to solve the problem.
  For a sequential algorithm, this is identical to the algorithm's time.
]) <def:work>

An algorithm's work estimates the amount of total computation done by the algorithm, irrespective of the number of available processors.

With these two definitions, we can now define what it means for a parallel algorithm to be efficient:

#definition(title: [Work-Efficiency @blelloch_parallel_1996], [
  We call a parallel algorithm operating on an input of size $n$ work-efficient, if and only if $W(n) = cal(O)(T^*(n))$
]) <def:work-efficiency>

That is, an algorithm is work-efficient if it asymptotically does the same work as the best known sequential algorithm. 

However, since @def:time and @def:work do not consider the number of processors, the question may arise how these metrics translate to a machine with a limited number of $p$ processors. This problem is solved by @theo:scheduling-principle

#theorem(title: [Work-Time Scheduling Principle @jaja_introduction_1992], [
  A parallel algorithm with work $W(n)$ and time $T(n)$ can be executed on a PRAM with $p$ processors using $O((W(n)) / p + T(n))$ parallel steps.
]) <theo:scheduling-principle>


=== Example

Let us consider the problem of summing all values in an array $A[1..n]$.

#todo[probably cite this from somewhere]

#figure(caption: [A visualization of the addition problem.], 
  image(width: 70%, "gfx/par_plus.svg")
) <fig:par-plus>

For simplicity, we assume that $n$ is a power of two.
A sequential algorithm to solve this is to iterate through the array and sum every into an accumulator. It is easy to see that this algorithm requires $cal(O)(n)$ time. 
So we have $T^*(n) = cal(O)(n)$.

For the parallel version, we have every processing unit add a value at an even index to its neighbor to the right.
This yields $n/2$ new values. This process is repeated until there is only one value left, which is the result. As we can only divide $n$ by two $lg n$ times, this results in $T(n) = cal(O)(lg n)$ time. 
We can also see that the total work required for this algorithm is $cal(O)(n)$. Since as depicted in @fig:par-plus, this algorithm can be visualized as a binary tree with $n$ leaves. This results in $n-1$ internal nodes, which each represent one addition. So, $W(n) = cal(O)(n)$.

To reach the above time, we obviously need $p >= n/2$ processors to be available.
If we were to run this algorithm on a machine with $p < n/2$ processors, omitting most of the $cal(O)$-Notation for simplicity, we can use @theo:scheduling-principle to get
$ T_p(n) = cal(O)((W(n))/p + T(n)) = cal(O)(n/p + lg n) = cal(O)(n/p + lg n) $
We can see, that the optimal number of processors would be $p = cal(O)(n/(lg n))$ so that $T_p(n) = cal(O)(n)$.

