#import "utils.typ": * 

= Block Trees

The block tree was first described by Belazzougui et al. @belazzougui_block_2021
and allows access to the underlying string in logarithmic time while only requiring space approximating the LZ77 parsing @ziv_universal_1977 of the text.
It also offers other operations like rank and select queries at the cost of extra space. 
In the following, we will describe the block tree and its original construction algorithm more in depth.

#definition(title: [Block Tree @belazzougui_block_2021])[
Let $S in Sigma^n$ be a string over the alphabet $Sigma$.
In addition, let $tau > 1$ and $s > 1$ be extra parameters.
The _block tree_ is a tree-like data structure whose root has arity $s$ and every other node with children has arity $tau$.
Each node represents a segment of the text.
A node on layer $h$ (where layer $0$ is the root node) represents a segment of the text of length $n / (s dot.op tau^(h-1))$ for $h>0$.
We call these segments _blocks_.
There can be three types of blocks:

+ _Internal blocks_, which have $tau$ children, dividing their parent node into $tau$ equal-sized blocks. 
+ _Back blocks_, which are leaves, but point to a block on the same level to the left of them called the _source block_. The property that holds here is that the content of this block must be the same as the content in the source block. Note, that the copied content may start at an offset in the source block.
+ _Leaf blocks_, which are exclusively the blocks on the last level. These store their substring of $S$ verbatim.
] <def:blocktree>

An example block tree is depicted in @fig:mmblocktree.

#figure(
  caption: [
    An example block tree (from "The Muffin Man"). Note, that while here the arity varies between the levels, this is only the case to make this example more clear.
    Back blocks are depicted with dashed lines and the blocks they point to are dotted arrows.
    The last layer of the tree is saved verbatim. For the pruned version of this tree, see @fig:mmblocktree_pruned.
  ], 
  image(
    "gfx/mmblocktree.svg",
    width: 100%,
  )
) <fig:mmblocktree>

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

To accomplish this, for a second pass we create another hash table containing the Rabin-Karp hash for all of the aforementioned blocks.
Note that we hash single blocks now.
We then scan once again with a sliding window, this time equal to the length of a block.
Upon finding a block $B_i$'s earlier occurrence, say in blocks $B_j$ and $B_(j+1)$ at offset $l < |B_j|$, instead of $B_i$ we store a pointer to $B_j$ and $B_(j+1)$ with $l$ as its offset.
This denotes, that $B_i$'s content is to be copied from $B_j$ starting at index $l$.

All remaining blocks are again subdivided into $tau$ children and the process is repeated for the next layer.
We terminate the recursion, once the blocks are so small, that they fit into $Theta(lg_sigma n)$ bits if we were to save their content verbatim.
At this point, the pointers we would need to save for back blocks and internal blocks would dominate the space required by the block's content.

After construction as described, a block tree would look like the one in @fig:mmblocktree

The question may arise, why we need two passes, once scanning for block pairs and single blocks in the second pass.
At first glance, it would seem reasonable to merely scan for single blocks and identify leftmost occurrences, 
then replace blocks once an earlier occurrence is found.
However, this could lead to the situation depicted in @fig:single_pass_bt_problem.
If only one pass is used, this might lead to back blocks, pointing to other back blocks.

However, if we first search for block pairs and only replace blocks $B_i$ for which both $B_(i-1) B_i$ and $B_i B_(i+1)$ have an earlier occurence,
then then there is no other block pointing to $B_i$.
#proof[
  Say there is a back block $B_j$ with $j > i$ where the range it copies from overlaps $B_i$. Then either $B_j$ points to $B_(i-1)$ or $B_i$ itself.
  If it is the former, then it should instead point to the earlier occurrence of $B_(i-1) B_i$ since it is further to the left.
  In the latter case, it should point to the earlier occurrence of $B_i B_(i+1)$ instead.
  This is a contradiction with the fact that $B_j$ points to $B_i$.
]

When a query is made, this can lead to the query having to follow long chains of pointers on each level of the tree, 
impacting performance and invalidating the logarithmic performance guarantees.
On the other hand, this results in us potentially missing many opportunities for inserting back pointers.
This problem is handled in the subsequent pruning step.

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

As seen in @fig:mmblocktree, there is still redundancy in the block tree after the construction described until this point.
For example, the second #inlinebox[M M] block on the third level of the tree (block $5$), could be replaced with a pointer to the first #inlinebox[M M] block (block $2$);
We discussed in the previous section, that issues arise, when a back block points to another back block,
which could occur if we were not to fingerprint block pairs when marking blocks.
So, if we notice that there is no back block pointing to the block $B_i$, then we can replace $B_i$ with a pointer in case it has an earlier occurrence.

To solve this issue we prune the tree after construction.
We modify the second pass of the construction slightly in that we do not only insert the hashed of blocks that are to be replaced,
but rather _all_ blocks.
When we encounter an earlier occurrence of some block, we save its position but do not replace it yet.

After construction, we assign a counter to each block in the tree, initialized to zero, which counts how many back blocks are pointing to it.
We now traverse the tree in post-order from right to left, handling the parent node after the children.
Upon reaching a back block $B_i$ that points to $B_j$ and possibly $B_(j+1)$, we increment the counter for $B_j$ and if applicable $B_(j+1)$.
If we reach a block $B_i$ that has a counter of zero and all its children are either back blocks or leaf blocks (see @def:blocktree), then we replace $B_i$ and its children with a back pointer if there is an earlier occurrence.
In doing so, we need to take care to decrement the counters of the blocks $B_i$'s children pointed to in case they were back blocks.
Note, that we can only do this if $B_i$'s previous occurrence does not overlap itself.

With this step done, the block tree from @fig:mmblocktree after pruning is depicted in @fig:mmblocktree_pruned.

#figure(
  caption: [
    The block tree from @fig:mmblocktree after pruning.
  ], 
  image(
    "gfx/mmblocktree_pruned.svg",
    width: 100%,
  )
) <fig:mmblocktree_pruned>
