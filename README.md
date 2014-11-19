
Software Evolution, Series 1
============================

StudentID : 6131085
Author    : Fabiën Tesselaar
Email     : fabientesselaar@gmail.com


# Maintainability numbers

## Provided by course:
                          Files  LOC      Duplicates   Complexity
SmallSQL (as-is)          186    24,300   11%          74% / 8% / 12% / 6%
HSQLDB (only hsqldb/src)  535    169,600  16%          64% / 14% / 12% / 10%
  

## My results
                          Files  LOC      Duplicates   Complexity
SmallSQL (as-is)          186    24,108   10% or 7%   71.5% / 9% / 13% / 6.5%
HSQLDB (only hsqldb/src)  535    168,308  ??           62% / 15% / 13% / 10%
  


# Motivation per metric

## LOC & Volume
Both look at the same amount of files. The M3@documentation does not include all comments, so the LOC count should be lower than provided as course results.

### Data
smallSql = ("total":38423, "cleaned":24108, "score":"++", "files":186)
largeSql = ("total":298084,"cleaned":168308,"score":"+",  "files":535)


## Unit complexity
There is a small deviation. I only consider LOC inside units (including comments and empty lines) as the paper speaks of "relative comments". My motivation is that as all units have additional lines, on average, they do not play a role, but it is faster for not computing unwanted lines.

### Data
smallSql = (
  "no risk"                    : 0.7165629270,
  "moderate risk"              : 0.09083548403,
  "high risk"                  : 0.1270178635,
  "untestable, very high risk" : 0.06558372552
)

largeSql (
  "no risk"                    : 0.6190688156,
  "moderate risk"              : 0.1521357964,
  "high risk"                  : 0.1251078891,
  "untestable, very high risk" : 0.1036874990
)

## Duplication
SmallSql = Duplication:  0.09858678396

If a block is found again, it is a clone of multiple blocks
i.e A ... A       = 12 duplicate lines
    A ... A ... A = 18    ,,    ,,
  
But consider: AB ... A ... AB =? AB + AB + (A + A + A) ??
     
Since it is only supposed to be a simple metric, I consider two cases:

  a) 12 lines: Group them for the unique lines, this way a clone of more
  than 6 lines is counted correctly.

  {1,2,3,4,5,6} + {9,10,11,12,13,14}
  {2,3,4,5,6,7} + {10,11,12,13,14,15} = {1, .., 7} + {9, .., 15}
             
  It will count too few lines if the following two duplicates are found:
  {4,5,6,7,8,9} + {90,91,92,93,94,95} as {4,5,6} is already inside a found block.

  b) More than 12 lines: Multiple parts in the code used the exact same lines, thus count them all. This would add too many in the edge cases.



## Notes

Building the ASTs and M3 model takes 70% - 80% of the computing time for a single metric and 60% - 70% calculating the four metrics (volume, unit size, unit complexity and duplication).