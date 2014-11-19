module Duplication

import IO;
import Set;
import List;
import String;
import Map;

import Util;

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
	
num projectDuplication(asts, documentation, blockSize) {
	num totalLOC  = 0;

	list[str] lines	= [];
  	
    for (ast <- asts) {
    	totalLOC += ast@src.end.line;

		// Get lines that are not comments or empty
		list[str] fileLines = removeCommentsInFile(ast@src, documentation[ast@src.top]);

		int N = size(fileLines);
		
		// Skip files without enough content
		if (N < blockSize)
			continue;

		// Remove all whitespacing
		lines += removeWhitespace(fileLines);
	}
	
	map[str, set[int]] lineBlocks = lineBlocks(lines, blockSize);
	
	return clonedLines(lineBlocks, blockSize) / totalLOC;
}


// Create mapping (blockSized lines concatenated : numbers to count unique duplicate lines)
map[str, set[int]] lineBlocks(list[str] lines, blockSize) {
	result = ();
	
	for (i <- [0 .. size(lines)-blockSize], block := intercalate("", lines[i .. i+blockSize]), !unNeededBlock(block)) {	
		numbers = {c | int c <- [i .. i+blockSize]};
		
		if (block in result)
			result[block] += numbers;
		else
			result += (block : numbers);
	}
	
	return result;
}

// Rather difficult to give a name
// Skip blocks starting or ending "{" "}" as it makes blocks
// seem like code clones faster... without providing functionality
bool unNeededBlock(str block) =
	startsWith(block, "{") || endsWith(block, "}") ||
	startsWith(block, "}") || endsWith(block, "{");


// Count LOC in two types of clones (see Readme.md for more info)
num clonedLines(lineBlocks, blockSize) {
	result  = 0;
	uniques = {};
	
	for (k <-lineBlocks, size(lineBlocks[k]) >= 2*blockSize) {	
		if (size(lineBlocks[k]) == 2*blockSize) {
			uniques += lineBlocks[k];
			continue;
		}
		
		result += size(lineBlocks[k]);
	}
	
	return result + size(uniques);
}



// The idea is that duplicate code is "only" located in units, thus 
// reducing the amount of lines by ~40% to see if it works for largeDB
num projectDuplicationExperiment(asts, documentation, blockSize) {
	num totalLOC  = 0;
  	int counter	  = 1;

	list[str] lines = [];
  	
	visit(asts) {
		case cu : \compilationUnit(_,_,_) : {
			totalLOC += cu@src.end.line;
		}
		
		case m : \method(_, _, _, _, _) : {
			unitLines = cleanUnitLines(m@src);
			
			if (size(unitLines) >= blockSize)
				lines += removeWhitespace(unitLines);
		}
		
		case c : \constructor(_, _, _, _) : {
			unitLines = cleanUnitLines(c@src);
					
			if (size(unitLines) >= blockSize)
				lines += removeWhitespace(unitLines);
		}
	}
	
	int N = size(lines);
	
	// Project is too small for duplicate lines
	if (N < 6)
		return 0;
	
	map[str, set[int]] lineBlocks = lineBlocks(lines, blockSize);
	
	return clonedLines(lineBlocks, blockSize) / totalLOC;
}

/* 
  Super slow and cannot count multiple clones with 
  the same block code properly, but feels like a solution in 
  Rascal...
*/
num countDuplicateLinesSlow(list[str] lines) {
	duplicates = {};

	for ([*X, A,B,C,D,E,F,  *Y,  A,B,C,D,E,F, *Z] := lines) {
    	offset1 = size(X) + 1;
    	offset2 = size(X) + size(Y) + 7;

    	duplicates += { 
      		i, j | i <- [offset1 .. offset1+6], 
        	       j <- [offset2 .. offset2+6]
        };
	}
  
 	return size(duplicates);
}
