#import "utils.typ": *
#import "template.typ": *

= Introduction

== Motivation

Over the course of the past few decades, the volume of available data has skyrocketed and, as such, has created new challenges for storing and working with this data.
So, methods for handling this growth are becoming more relevant by the second.
One example relevant to this thesis is the field of bioinformatics.
The first genomes sequenced in the 1970s consisted only of a few thousand nucleotides #cite("fiers_complete_1976", "sanger_nucleotide_1977"). 
However, in recent times, genomes up to 43 billion nucleotides in length have been sequenced @meyer_giant_2021.

In bioinformatics, text indexing plays a major role, facilitating efficient searches in genomes @vyverman_prospects_2012.
Data structures that index texts are known in the literature, notable examples being Ferragina and Manzini's #emph[FM-index] @p_ferragina_opportunistic_2000 and Gagie et al.'s #emph[r-index] @gagie_optimal-time_2018.

Many such indices require efficient #emph[access], #emph[rank], and #emph[select] queries on arbitrary strings over an ordered alphabet to facilitate searches using them.
Traditionally, data structures like the #emph[wavelet tree] @grossi_high-order_2003 have been used to implement rank and select queries on strings.
While the Wavelet Tree can be compressed to require asymptotically equal space to the Huffman-compressed text @huffman_method_1952, this does not adequately take advantage of the redundancies contained in highly repetitive text.
An example of such repetitive texts is collections of DNA sequence.

One method of taking advantage of redundancies in repetitive texts is the #emph[LZ77 parsing] @ziv_universal_1977 by Lempel and Ziv.
As an important component of popular compressors like #emph[gzip]#urlfootnote("https://www.gzip.org/", [30.05.23]), work has been done on approximations with more efficient construction #cite("bille_lempel-ziv_2017","ferreira_time_2009") and parallel implementations of the parsing @shun_practical_2013.
While it is a parsing well-known for being able to exploit repetitiveness for compression, it is also known to be difficult to access arbitrary subsequences from an LZ77-compressed text efficiently @kreft_lz77-like_2010.
For this reason, schemes approximating LZ77 while still allowing efficient retrieval of substrings have been proposed in the literature #cite("kreft_lz77-like_2010", "belazzougui_block_2021").

While at first glance departing from the usual idea of the LZ77 parsing, Belazzougui et al.'s #emph[block tree] @belazzougui_block_2021 is one such approximation
which allows efficient access, rank and select queries while only requiring space approximating the size of the text's LZ77 parsing @ziv_universal_1977.
It is a tree-like structure, recursively dividing the text into blocks and replacing repeated text segments with a pointer to the left on the same level
and has recently been successfully used to encode the topology of a suffix tree with a good space-time tradeoff @caceres_faster_2022.

== Problem

While the block tree allows storing the text efficiently, there are still avenues for improvement in its construction.
The construction algorithm described in the original paper @belazzougui_block_2021 does not offer parallelism and as such,
does not take advantage of the many cores available in modern processors.

= Goals <sec:goals>

The goal of this thesis is to accelerate the original block tree construction algorithm through parallelism while ideally staying asymptotically close to the memory consumption of the original algorithm.
While the block tree allows for rank and select operations with additional data structures,
it is not expected for the calculation thereof to play any significant part in the run time requirements of the algorithm.
As such, the focus of this thesis will be on the block tree for access queries.

== Main Goal

Since the access to hash tables is most significant time sink in the original algorithm,
the main objective of this thesis is to accelerate the manner in which hash tables are used.
For each level in the tree, each block's Rabin-Karp fingerprint @rabin_fingerprinting_1981 needs to be saved in a hash table, along with the position of its left-most occurrence in the text.
If there are conflicts, smaller positions take precedence.
The first improvement is to split the text into roughly equal segments and have each processor handle one of these segments, 
writing and reading concurrently to the hash table.

There are at least two ways to approach this.
The first one is the use of a global concurrent hash table to and from which every thread can write and read concurrently.
One problem that could arise is that multiple threads write to locations in the hash table that are close to each other.
This could lead to cache invalidation and thus reduce performance.

To remedy this, one can try to use sharding.
We instead use one hash table per processor and only allow one processor to access each hash table. 
The hash tables together cover a contiguous range of keys, but the hash table's ranges are being pairwise disjunct.
Whenever a read or write is requested by any processor $p$, it can identify the processor $q$ whose part of the hash table would contain the hashed value.
The operation is then inserted into a queue for processor $q$ and subsequently handled by $q$.

== Minor Goals

Beyond hash tables there might be other improvement options, albeit of lesser importance.
Since a large amount of Rabin-Karp hashes must be calculated, it is plausible that improvements to the hashing itself might lead to performance improvements.
There have been implementations of the Rabin-Karp search algorithm which use the GPU #cite("shah_improved_2018", "moeini_parallel_2019"), so acceleration of hashing using the GPU might be possible.
Alternatively, acceleration using SIMD instructions might also prove efficient.

Each level in the block tree contains a bit vector marking which blocks are replaced by pointers and which are internal blocks containing children.
In addition, for each level the back pointers and corresponding offsets need to be saved.
An improvement option is the use of parallel vectors and bit vectors which allow parallel writes and reads.

The last improvement is the compression of the aforementioned bit vectors.
For this purpose we can save the bit vectors as block trees themselves.
For binary alphabets, it might be possible to achieve greater space efficiency by exploiting properties of the binary alphabet. 
This results in a recursive data structure.
Of course, block tree-compressed bit vectors will not offer the same performance as uncompressed bit vectors and as such,
the recursion depth to which this compression is worth it, remains to be explored through testing. 

= Method

== Tools

We will implementing in C++ using OpenMP#urlfootnote("https://www.openmp.org/", [30.05.23]) for parallelism.
The concurrent hash map implementation#urlfootnote("https://github.com/TooBiased/growt", [30.05.23]) to be used is by Maier et al. @maier_concurrent_2019.
For compressed vectors, Patrick Dinklage's implementation will be used#urlfootnote("https://github.com/pdinklag/word-packing", [30.05.23]) and Florian Kurpicz' implementation#urlfootnote("https://github.com/pasta-toolbox/bit_vector", [30.05.23]) #todo[cite florian's paper] for bit vectors with rank and select support.
Our block tree implementation will be compared to the one by Manuel Cáceres'#urlfootnote("https://github.com/elarielcl/MinimalistBlockTrees", [30.05.23]).
We will test all implementations on large, primarily repetitive, texts such as those from the Pizza & Chili corpus#urlfootnote("http://pizzachili.dcc.uchile.cl/", [30.05.23]).

These are subject to change, in case better-suited alternatives are found or problems arise.

== Outline

The first section will be a brief introduction into the topic, which is followed by a section of theoretical foundations relevant to this thesis.
Next, we describe block trees themselves and their construction more extensively.
This is followed by a description of implementation details for the implementation of this thesis.
The last two sections will be a practical evaluation and a closing section discussing the results and future possible work.
The resulting tentative outline is as follows:

1. Introduction
2. Theoretical Foundations
3. Block Trees
4. Parallelization
5. Implementation
6. Evaluation
7. Conclusion

== Time Schedule

An approximate preliminary time schedule is depicted in @tab:thesis-time-schedule.
Weekly meetings should be arranged to ensure consistent progress.

#let schedule-color = blue;
#figure(caption: [Preliminary time schedule.])[
  #text(font: sans-serif, table(
    columns: (1fr, auto, auto, auto, auto, auto, auto),
    inset: 10pt,
    align: horizon,
    fill: (col, row) => {
      if row == 1 and col >= 1 and col <= 2 {
        schedule-color
      } else if row == 2 and col >= 1 and col <= 3 {
        schedule-color
      } else if row == 3 and col >= 3 and col <= 4 {
        schedule-color
      } else if row == 4 and col == 4 {
        schedule-color
      } else if row == 5 and col >= 4 and col <= 5 {
        schedule-color
      } else if row == 6 and col == 6 {
        schedule-color
      }
    },
    [*Month*], [*1*], [*2*], [*3*], [*4*], [*5*], [*6*], 
    [Research (Sec. 2+3)], [], [], [], [], [], [], 
    [Implementation (Sec. 4+5)], [], [], [], [], [], [], 
    [Evaluation (Sec. 6)], [], [], [], [], [], [], 
    [Introduction & Conclusion (Sec. 1+7)], [], [], [], [], [], [],
    [Revision], [], [], [], [], [], [],
    [Buffer], [], [], [], [], [], [], 
  ))
] <tab:thesis-time-schedule>
