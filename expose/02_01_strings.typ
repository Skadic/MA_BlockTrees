#import "utils.typ": *

#definition(title: "Strings", [
Let $Sigma := {c_1, dots, c_sigma}$ be a set of characters called the #emph[alphabet] with size $sigma := |Sigma|$ with $c_1 < c_2 < dots < c_sigma$.
If $s_1, dots, s_n in Sigma$, then we call the concatenation of these characters
$S[1..n] = s_1 s_2 dots s_n in Sigma^*$ a _string_ of length $n$ over the alphabet $Sigma$.
$S[i..j] := s_i dots s_j$ for $i <= j$ is a substring of $S$. 
Similarly, for strings $S_1, S_2 in Sigma^*$, $S' := S_1 S_2$ denotes the concatenation of $S_1$ and $S_2$.
Substrings $S[1..i]$ and $S[i..n]$ are called #emph[prefix] and #emph[suffix] respectively.
]) <def:string>


