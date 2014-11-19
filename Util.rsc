module Util

import IO;
import String;
import List;
import Set;
import Map;

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;


list[str] removeWhitespace(list[str] lines) =
	[ removeWhitespace(l) | l <- lines ];

str removeWhitespace(str txt) = visit(txt) {
	case /[\ \t\n\r]/ => ""
};

list[str] removeEmptyLines(list[str] lines) = 
    [trim(L) | L <- lines, size(trim(L)) > 0];



list[str] cleanUnitLines(loc unitSrc) {
	unitLines = readFileLines(unitSrc);
	unitLines = removeForgottenComments(unitLines, dangerZone=true);
	unitLines = removeEmptyLines(unitLines);
	
	return unitLines;
}

// Group comments by file
map[loc, set[loc]] M3CommentsByFile(rel[loc, loc] documentation) {
	result = ();
  
  	// TODO ask for Rascal trick to do this in one-liner
  	for (D <- documentation)
		if (D[1].top in result)
      		result[D[1].top] += {D[1]};
    	else
      		result += (D[1].top : {D[1]});  
  
  	return result;
}


list[str] removeCommentsInFile(loc file, set[loc] comments) {
	// Line numbers are off by one
    list[str] lines = [""] + readFileLines(file);
    
    if (!isEmpty(comments))
		lines = removeComments(lines, comments);
		        
    lines = removeEmptyLines(lines);
    
    // M3 cannot find block comments, so manually remove them
    if ("*/" in lines)
    	lines = removeForgottenComments(lines);
    
    return lines;
}


list[str] removeComments(list[str] lines, set[loc] comments) {
	for (C <- comments) {
    	// Check if it is a single of multi-line comment
    	begin = C.begin.line;
	    end   =	C.end.line;
    	diff  = end - begin;
    
    	if (diff == 0) { 
    		// If entire "single line" is a comment, remove it 
    		if (isLineComment(lines[begin])) {
				lines[begin] = "";
				continue;
			}
    		// Remove inline comment
    		else {
    			str temp = substring(lines[begin], 0, C.begin.column) +
	    				   substring(lines[begin], C.end.column);
	    		
	    		lines[begin] = temp;
    		}
    	}
    	
    	if (diff > 0) {
    		// Simple block comments
    		if (isSimpleBlockComment(lines[begin], lines[end])) {
	    		for (int i <- [begin .. end+1])
	    			lines[i] = "";
	    	}
	    	else {
	    		// Some code present before or after the block comment
	    		// (this almost never happens)
	    		lines[begin] = substring(lines[begin], 0, C.begin.column);
	    		lines[end]	 = substring(lines[end], C.end.column);
	    		
	    		if (diff > 1)
	    			for (int i <- [begin+1 .. end])
	    				lines[i] = "";
	    	}
	    }
	}
	
	return lines;
}


// Use for left-over doc blocks 

// If dangerZone is on, it will also do non-greedy removal 
// of multiline comments (even if they are inside regex or comments
list[str] removeForgottenComments(list[str] lines, bool dangerZone=false) {
	bool inComment = false;

	return for (L <- lines, !isLineComment(L)) {		
		if (isStartComment(L)) {
			inComment = true;
		}
		else if (dangerZone && findFirst(L, "/*") >= 0) {
			append substring(L, 0, findFirst(L, "/*"));
			inComment = true;
		}
		
		// Find closing statement as near as possible
		if (inComment && findFirst(L, "*/") >= 0) {
			append substring(L, findFirst(L, "*/")+2);
			
			inComment = false;
			continue;
		}
	
		if (! inComment) {
			append L;
		}
	}
}


bool isLineComment(str line) = 
	startsWith(trim(line), "//") || isSimpleBlockComment(line, line);

bool isSimpleBlockComment(str begin, str end) = 
	isStartComment(begin) && isEndComment(end);

bool isStartComment(str line) = startsWith(trim(line), "/*");
bool isEndComment(str line)   = endsWith(trim(line), "*/");
