#import "utils.typ": * 

= Block Trees

The #emph[Block Tree] is a data structure on strings first described by Belazzougui et al. @belazzougui_block_2021
which allows access to the string in logarithmic time while only requiring space approximating the LZ77 parsing @ziv_universal_1977 of the text.
It also offers other operations like rank and select queries at the cost of extra space. 
In the following, we will describe the Block Tree and its original construction algorithm more in depth.


#definition(title: [Block Tree @belazzougui_block_2021])[
  Let $S in Sigma^n$ be a string over the alphabet $Sigma$.
  In addition, let $tau > 1$ and $s > 1$ be extra parameters.
  The #emph[Block Tree] is a tree-like data structure whose root has arity $s$ and every other node with children has arity $tau$.
  Each node represents a segment of the text.
  A node on layer $h$ (where layer $0$ is the root node) represents a segment of the text of length $n / (s dot.op tau^(h-1))$ 
  There can be three types of blocks:
  + Internal blocks, which have $tau$ children, dividing their parent node into $tau$ equal-sized blocks. 
  + Back blocks, which are leaves, but point to a block on the same level to the left of them called the #emph[source block]. The property that holds here is that the content of this block must be the same as the content in the source block. Note, that the copied content may start at an offset in the source block.
  + Leaf blocks, which are exclusively the blocks on the last level. These store their substring of $S$ verbatim.
]



