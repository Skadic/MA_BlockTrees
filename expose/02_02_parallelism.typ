#import "utils.typ": *

== Parallelism

For sequential algorithms, the notion of runtime is usually sufficient when trying to evaluate the time efficiency of an algorithm.
However, for parallel algorithms, additional metrics are of use. The concepts and descriptions decribed here are taken from Jájá's book @jaja_introduction_1992 on the subject.

#definition(title: [Time and Cost @jaja_introduction_1992], [
  Say the input size is $n$ and we use $P(n)$ processors.
  For a parallel algorithm, the _time_ $T(n)$ is the number of parallel time steps an algorithm requires 
  on a machine with $P(n)$ processors.
  The _cost_ is then given by $C(n) = T(n) dot.op P(n)$ and provides measure of the number of computations relative to the number of processors used.
]) <def:timecost>

With just one processor, this provides us with an algorithm running in $cal(O)(C(n))$ time.
This is achieved by the processor simulating the behavior of all $P(n)$ processors for each of the $T(n)$ time steps.
This generalizes to any number $p <= P(n)$ of processors by requiring $cal(O)(T(n) dot.op (P(n))/p)$ time in total,
//by simulating the $W_i(n)$ instructions from time step $i$ in $ceil((W_i(n))/p)$ steps each.
and leads to four asymptotically equivalent ways of measuring performance:
- $P(n)$ processors and $T(n)$ time.
- $C(n) = P(n) dot.op T(n)$ cost and $T(n)$ time
- $cal(O) (T(n) (P(n)) / p)$ time for any number $p <= P(n)$ of processors
- $cal(O)((C(n))/p + T(n))$ time for any number $p$ of processors

However, in designing algorithms we will be using the _Work-Time_ model @jaja_introduction_1992,
which offers a simple way to quantify the complexity of a parallel algorithm.

#definition(title: [Work @jaja_introduction_1992], [
  For a parallel algorithm, the #emph[work] $W(n)$ performed on an input of size $n$ is defined by the total amount of operations required to solve the problem.
  For a sequential algorithm, this is identical to the algorithm's time.
]) <def:work>

Work estimates the amount of total computation required by the algorithm, irrespective of the number of processors.
An algorithm described in the work-time model can have any number of parallel computations in each parallel step.

Therefore, since @def:work does not consider the number of processors actually available (we could have less than the maximum amount of parallel computations used by the algorithm),
the question may arise how these metrics translate to a machine with a limited number of $p$ processors.
This problem is answered by @theo:scheduling-principle.

#theorem(title: [Work-Time Scheduling Principle @jaja_introduction_1992], [
  A parallel algorithm with work $W(n)$ and time $T(n)$ can be executed on a PRAM with $p < P(n)$ processors using $cal(O)((W(n)) / p + T(n))$ parallel steps.
  We write: $ T_p(n) = cal(O)((W(n)) / p + T(n)) $
]) <theo:scheduling-principle>

With these definitions, we can define what it means for a parallel algorithm to be efficient.
There are two concepts of optimality described by Jájá @jaja_introduction_1992:

#definition(title: [Optimality @jaja_introduction_1992], [
  Let $T^*(n)$ be the run time of the best sequential solution to a problem $Q$ on an input of size $n$.
  Any sequential algorithm with a run time of $cal(O)(T^*(n))$ is _time optimal_.
  A parallel algorithm solving $Q$ is called _optimal_ if $W(n) = Theta(T^*(n))$.
]) <def:work-efficiency> <def:optimality>

That is, an algorithm is optimal if it asymptotically does the same work as the best known sequential algorithm. 
The above definition is irrespective of the actual run time of the algorithm, 
and merely compares the work performed by both algorithms.
Remember that for sequential algorithms, the notion of work and time are equivalent.
This definition is equivalent to the definition of work-efficiency by Blelloch and Maggs @blelloch_parallel_1996.

To include the actual run time into the notion of optimality, there is a second, stronger definition of optimality.

#definition(title: [Work-Time Optimality @jaja_introduction_1992], [
  An optimal algorithm with a run time of $T(n)$ is called work-time optimal, 
  if it can be shown, that $T(n)$ is the fastest-possible time attainable by any optimal parallel algorithm.
]) <def:work-efficiency>

In other words, an algorithm is work-time optimal if its runtime cannot be improved upon without increasing the number of operations.

Lastly, we quantify the speedup of a parallel algorithm over the best sequential solution.

#definition(title: [Speedup @jaja_introduction_1992], [
Let $P$ be a problem with an input size of $n$ and $P$ be solved by a sequential algorithm 
in $T^*(n)$ time, where $T^*(n)$ is the lower bound for any sequential solution of $P$.
Then let $A$ be a parallel algorithm that solves $P$ with $p$ processors in $T_p(n)$ time.
We call the _speedup_ achieved by $A$ to be $ S_p(n) = (T^*(n)) / (T_p(n)). $
]) <def:speedup>

The meaning of speedup is intuitive. If a parallel algorithm requires half the time that the sequential algorithm required, then the corresponding speedup will be $2$.
Also, since $T^*(n)$ is not always known formally, it is common to use the complexity of the best known sequential algorithm @jaja_introduction_1992.

We know we can simulate an optimal algorithm on $p$ processors using time $cal(O) ((T^*(n)) / p + T(n))$.
With this and @def:speedup, we find that the speed up for an optimal algorithm is given by:
$ S_p(n) = Omega((T^*(n)) / ( (T^*(p)) / p + T(n) )) = Omega( (p T^*(n)) / (T^*(n) + p T(n)) ) $
Since a speedup of $S_p(n) = Theta(p)$ would be ideal, we can see that $p=cal(O)((T^*(n))/(T(n)))$ is the desirable number of processors.

=== Example

#figure(caption: [A visualization of the addition problem.], 
  image(width: 70%, "gfx/par_plus.svg")
) <fig:par-plus>

Let us consider the problem of summing all values in an array $A[1..n]$.

For simplicity, we assume that $n$ is a power of two.
A sequential algorithm to solve this is to iterate through the array and sum every value into an accumulator.
It is easy to see that this algorithm requires $cal(O)(n)$ time. 
So we have $T^*(n) = cal(O)(n)$.

For the parallel version, we have every processor add a value at an even index to its neighbor to the right.
This yields $n/2$ new values. This process is repeated until there is only one value left, which is the result. As we can only divide $n$ by two $lg n$ times, this results in $T(n) = cal(O)(lg n)$ time. 
We can also see that the total work required for this algorithm is $cal(O)(n)$. Since, as depicted in @fig:par-plus, this algorithm can be visualized as a binary tree with $n$ leaves. This results in $n-1$ internal nodes, which each represent one addition. So, $W(n) = cal(O)(n)$.
As a result, this algorithm is optimal according to @def:optimality, since $W(n) = T^*(n)$.

If we were to run this algorithm on a machine with $p$ processors, omitting most of the $cal(O)$-Notation for simplicity, we can use @theo:scheduling-principle to get
$ T_p(n) = cal(O)((W(n))/p + T(n)) = cal(O)(n/p + lg n) = cal(O)(n/p + lg n) $
We can see, that the optimal number of processors would be $p >= P(n) = cal(O)(n/(lg n))$ so that $T_p(n) = cal(O)(lg n)$.

The resulting speedup is $ S_p(n) = (T^*(n))/(T_p(n)) = cal(O)((n) / (n/p + lg n)) $ and the optimal number of processors to reach this speedup is again $p = (T^*(n))/(T(n)) = n/(lg n)$
