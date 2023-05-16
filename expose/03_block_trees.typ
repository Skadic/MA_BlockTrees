#import "utils.typ": * 

= Block Trees

The Block Tree was first described by Belazzougui et al. @belazzougui_block_2021
and allows access to the underlying string in logarithmic time while only requiring space approximating the LZ77 parsing @ziv_universal_1977 of the text.
It also offers other operations like rank and select queries at the cost of extra space. 
In the following, we will describe the Block Tree and its original construction algorithm more in depth.

#definition(title: [Block Tree @belazzougui_block_2021])[
Let $S in Sigma^n$ be a string over the alphabet $Sigma$.
In addition, let $tau > 1$ and $s > 1$ be extra parameters.
The _Block Tree_ is a tree-like data structure whose root has arity $s$ and every other node with children has arity $tau$.
Each node represents a segment of the text.
A node on layer $h$ (where layer $0$ is the root node) represents a segment of the text of length $n / (s dot.op tau^(h-1))$ for $h>0$.
We call these segments _blocks_.
There can be three types of blocks:

+ _Internal blocks_, which have $tau$ children, dividing their parent node into $tau$ equal-sized blocks. 
+ _Back blocks_, which are leaves, but point to a block on the same level to the left of them called the _source block_. The property that holds here is that the content of this block must be the same as the content in the source block. Note, that the copied content may start at an offset in the source block.
+ _Leaf blocks_, which are exclusively the blocks on the last level. These store their substring of $S$ verbatim.
] <def:blocktree>

#pagebreak()
== Original Construction Algorithm

The original block tree construction algorithm @belazzougui_block_2021 builds the tree layer by layer starting at the topmost layer.
If $v$ is a node in the tree, we write $l_v$ to denote the level of the tree $v$ is found at.
The following definitions are in respect to the layer of the tree that is currently in discussion.
We call $B^v$ the block, that is the corresponding substring of $S$ while $B_i$ refers to the $i$-th block on this level.
The topmost layer is obtained by splitting the text into $s$ blocks of equal length.
For each layer, we proceed in the following way: 

We first identify all blocks that are supposed to be replaced with a pointer to an earlier occurrence.
Assign a counter with a starting value of $0$ to each block.
Then, create a hash table containing the Rabin-Karp hashes @rabin_fingerprinting_1981 of every pair of blocks on this level that are consecutive in the text.
We then scan through $S$ using a sliding window with the same size as a pair of blocks on this level.
If we find a window whose content is equal to a block pair $B_i B_(i+1)$ we saved to the hash table and
that window is an occurrence to the left of $B_i B_(i+1)$, we increase the counter for $B_i$ and $B_(i+1)$ respectively.
We only increase the counter once per pair of blocks respectively however.
In essence, we increase the counter of a block pair if we can find an earlier occurrence in $S$.

We then end up with counters in the range of zero to two (zero to one for the last block).
For a block $B_i$ with a counter equal to zero or one, at least one of $B_(i-1) B_i$ or $B_i B_(i+1)$ has no earlier occurrence.
For the last block, this is only the case if the counter is zero.
If $B_i$'s counter is two, then both $B_(i-1) B_i$ and $B_i B_(i+1)$ each have earlier occurrences.
It is these blocks (and the last block if its counter is one) that are slated to be replaced with a back block (see @def:blocktree).

To accomplish this, we create another hash table containing the Rabin-Karp hash for all of the aforementioned blocks.
Note that we hash single blocks now.
We then scan once again with a sliding window, this time equal to the length of a block.
Upon finding a block $B_i$'s earlier occurrence, say in blocks $B_j$ and $B_(j+1)$ at offset $l < |B_j|$, instead of $B_i$ we store a pointer to $B_j$ and $B_(j+1)$ with $l$ as its offset.
This denotes, that $B_i$'s content is to be copied from $B_j$ starting at index $l$.

All remaining blocks are again subdivided into $tau$ children and the process is repeated for the next layer.
We terminate the recursion, once the blocks are so small, that they fit into $Theta(lg_sigma n)$ bits if we were to save their content verbatim.
At this point, the pointers we would need need to save for back blocks and internal blocks would dominate the space required by the block's content.

The question may arise, why we need two passes, once scanning for block pairs and single blocks in the second pass.
At first glance, it would seem reasonable to merely scan for single blocks and identify leftmost occurrences, then replace blocks once an earlier occurrence is found.
However, this could lead to the situation depicted in @fig:single_pass_bt_problem.
If only one pass is used, this might lead to back blocks, pointing to other back blocks. When a query is made, this can lead to the query having to follow long chains of pointers on each level of the tree, 
impacting performance and invalidating the logarithmic performance guarantees.


#figure(
  caption: [
    Problems arise when only using a single pass. $B_i$ points to $B_j$ and $B_(j+1)$, however $B_(j+1)$ is itself a back block. 
    When queries are made on a back block, this might lead to the query having to follow long chains of pointers.
  ], 
  image(
    "gfx/single_pass_bt_problem.svg",
    width: 80%,
  )
) <fig:single_pass_bt_problem>

=== Pruning Step





