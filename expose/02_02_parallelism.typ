#import "utils.typ": *

== Parallelism

For sequential algorithms, the notion of runtime is usually sufficient when trying to evaluate the time efficiency of an algorithm.
However, for parallel algorithms, additional metrics are of use.
We will be using the #emph[Work-Time] model, which offers a simple way to quantify the complexity of a parallel algorithm.

#definition(title: [Time @jaja_introduction_1992], [
  Say the input size is $n$ and we use $P(n)$ processors. For a parallel algorithm, the #emph[time] $T(n)$ is the minimum number of time steps an algorithm requires on a machine with $P(n)$ processors.
  //$T(n)$ can also be characterized as the limit of $T_p(n)$ as $p$ approaches infinity.
]) <def:time>

#definition(title: [Work @blelloch_parallel_1996], [
  For a parallel algorithm, the #emph[work] $W(n)$ performed on an input of size $n$ is defined by the total amount of operations required to solve the problem.
  For a sequential algorithm, this is identical to the algorithm's time. The algorithm's work can also be characterized as the product of time and work. So $W(n) = P(n) T(n)$.
]) <def:work>

An algorithm's work estimates the amount of total computation done by the algorithm, irrespective of the number of available processors.

With these two definitions, we can now define what it means for a parallel algorithm to be efficient:

#definition(title: [Work-Efficiency @blelloch_parallel_1996], [
  We call a parallel algorithm operating on an input of size $n$ #emph[work-efficient] (or just #emph[efficient]), if and only if $W(n) = cal(O)(T^*(n))$,
  where $T^*(n)$ is the best known time of a sequential solution to the problem.
]) <def:work-efficiency>

That is, an algorithm is work-efficient if it asymptotically does the same work as the best known sequential algorithm. 

However, since @def:time and @def:work do not consider the number of processors actually available (we could have less than $P(n)$ processors available), the question may arise how these metrics translate to a machine with a limited number of $p$ processors. This problem is solved by @theo:scheduling-principle

#theorem(title: [Work-Time Scheduling Principle @jaja_introduction_1992], [
  A parallel algorithm with work $W(n)$ and time $T(n)$ can be executed on a PRAM with $p < P(n)$ processors using $cal(O)((W(n)) / p + T(n))$ parallel steps.
  We write: $ T_p(n) = cal(O)((W(n)) / p + T(n)) $
]) <theo:scheduling-principle>


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

If we were to run this algorithm on a machine with $p$ processors, omitting most of the $cal(O)$-Notation for simplicity, we can use @theo:scheduling-principle to get
$ T_p(n) = cal(O)((W(n))/p + T(n)) = cal(O)(n/p + lg n) = cal(O)(n/p + lg n) $
We can see, that the optimal number of processors would be $p >= P(n) = cal(O)(n/(lg n))$ so that $T_p(n) = cal(O)(lg n)$.

