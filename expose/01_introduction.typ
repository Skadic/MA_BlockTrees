#import "utils.typ": *
#import "template.typ": *

= Motivation

Over the course of the past few decades, the volume of available data has skyrocketed and, as such, has created new challenges for storing and working with this data. As such, methods for handling this growth are becoming more relevant by the second.
One example relevant to this paper is the field of bioinformatics.
The first genomes sequenced in the 1970s consisted only of a few thousand nucleotides #cite("fiers_complete_1976", "sanger_nucleotide_1977"). 
However, in recent times, genomes up to 43 billion nucleotides in length have been sequenced @meyer_giant_2021.

In this field, text indexing plays a major role, facilitating efficient searches in genomes @vyverman_prospects_2012.
Data structures that fulfill this purpose are known in the literature, notable examples being Ferragina and Manzini's #emph[FM-Index] @p_ferragina_opportunistic_2000 and Gagie et al.'s #emph[R-Index] @gagie_optimal-time_2018.

Many such indices, for example the aforementioned ones, require efficient #emph[access], #emph[rank] and #emph[select] queries on arbitrary strings over an ordered alphabet to facilitate searches using them.
Traditionally, data structures like the #emph[Wavelet Tree] @grossi_high-order_2003 have been used to implement rank and select queries on strings.
While the Wavelet Tree can be compressed to require asymptotically equal space to the Huffman-compressed text @huffman_method_1952, this does not adequately take advantage of the redundancies contained in highly repetitive text. 

One such scheme is the #emph[LZ77 parsing] @ziv_universal_1977 by Lempel and Ziv.
As an important component of popular compressors like #emph[gzip], work has been done on approximations with more efficient construction #cite("bille_lempel-ziv_2017","ferreira_time_2009") and parallel implementations of the parsing @shun_practical_2013.
While it is a parsing well-known for being able to exploit repetitiveness for compression, it is also known to be difficult to access arbitrary subsequences from an LZ77-compressed text efficiently @kreft_lz77-like_2010.
For this reason, schemes approximating LZ77 while still allowing efficient retrieval of substrings have been proposed in the literature #cite("kreft_lz77-like_2010", "belazzougui_block_2021").

While on its face departing from the usual idea of the LZ77 parsing, Belazzougui et al.'s #emph[Block Tree] @belazzougui_block_2021 is one such approximation
which allows efficient access, rank and select queries while only requiring space approximating the size of the text's LZ77 parsing @ziv_universal_1977.
It is a tree-like structure, recursively dividing the text into blocks and replacing repeated text segments with a pointer to the left on the same level
and has recently been successfully used to encode the topology of a suffix tree with a good space-time tradeoff @caceres_faster_2022.

= Problem

While the Block Tree allows storing the text efficiently, there are still avenues for improvement in its construction.
The construction algorithm described in the original paper @belazzougui_block_2021 does not offer parallelism and as such,
does not take advantage of the many cores available in modern processors.

= Goals

The goal of this thesis is to accelerate the original Block Tree construction algorithm through parallelism while ideally staying asymptotically close to the memory consumption of the original algorithm.

== Main Goal

The main goal is to improve the use of hash tables in the original algorithm.
It is the most significant time sink in the original algorithm, so the objective is to accelerate the manner in which hash tables are used.
For each level in the tree, each block's Rabin-Karp fingerprint @rabin_fingerprinting_1981 needs to be saved in a hash table,
The first improvement is to split the text and have each processor handle a segment of the input, 
writing and reading concurrently to the hash table.

There are at least two ways to approach this.
The first one is the use of a global concurrent hash table to and from which every thread can write and read concurrently.

Another option is to use sharding, instead using one hash table per processor and only allowing one processor to access each hash table. 
The hash tables together form one contiguous range, but being pairwise disjunct.
Whenever a read or write is requested by any processor $p$, it can identify the processor $q$ whose part of the hash table would contain the hashed value.
The operation is then inserted into a queue for processor $q$ and subsequently handled by processor $q$.
This might lead to improvements in cache efficiency.

== Minor Goals

Beyond hash tables there might be other improvement options, albeit of lesser importance.
Since a large amount of Rabin-Karp hashes must be calculated, it is plausible that improvements to the hashing itself might lead to performance improvements.
There have been implementations of the Rabin-Karp search algorithm which use the GPU #cite("shah_improved_2018", "moeini_parallel_2019"), so acceleration of hashing using the GPU might be possible.
Alternatively, acceleration using SIMD instructions might also prove efficient.

Each level in the Block Tree contains a bit vector marking which blocks are leaves and which are internal blocks containing children.
In addition, for each level the back pointers and corresponding offsets need to be saved. 
An improvement option is the use of parallel vectors and bit vectors which allow parallel writes and reads.

The last improvement is the compression of the aforementioned bit vectors.
For this purpose we can save the bit vectors as Block Trees themselves.
For binary alphabets, it might be possible to achieve greater space efficiency by exploiting properties of the binary alphabet. 
This results in a recursive data structure.
Of course, Block Tree-compressed bit vectors will not offer the same performance as uncompressed bit vectors and as such,
the recursion depth to which this compression is worth it, remains to be explored through testing. 

#let footnote(content) = {
  text(size: footnote-size, content)
}


= Tools

This will be implemented in C++ using #footnote[my footnote]
