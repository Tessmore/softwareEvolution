module Volume

import List;

import Util;

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;


map[str, value] projectVolume(asts, map[loc, set[loc]] documentation) {
	int total   = 0;
	int cleaned = 0;
	int files   = 0;
  
    for (ast <- asts) {
  		files += 1;
    	total += ast@src.end.line;

    	list[str] lines = removeCommentsInFile(ast@src, documentation[ast@src.top]);

    	cleaned += size(lines);
  	}
    
  	return (
    	"files"   : files, 
    	"total"   : total, 
    	"cleaned" : cleaned,
    	"score"   : volumeScore(cleaned)
  	);
}


// volume score by KLOC as defined in "Practical maintainability"
str volumeScore(int LOC) {
    real KLOC = LOC / 1000.0;

  	if (KLOC < 66)
    	return "++";
  	else if (KLOC < 246)
    	return "+";
  	else if (KLOC < 665)
    	return "0";
  	else if (KLOC < 1310)
    	return "-";
  	else
    	return "--"; 
}
