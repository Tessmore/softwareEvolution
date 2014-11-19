module UnitSize

import String;
import List;
import Set;
import Map;

import Util;

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;


map[loc, int] projectUnitSize(asts) {
	num totalLOC = 0;
	map[loc, int] units = ();
  	
	visit(asts) {
		case cu : \compilationUnit(_,_,_) : {
			totalLOC += cu@src.end.line;
		}
		
		// Opening and closing line don't count so "lines - 2"
		case m: \method(_, _, _, _, statement) : {
			units += (m@src : size(cleanUnitLines(statement@src)) - 2);			
		}
		
		case c: \constructor(_, _, _, statement) : {
			units += (c@src : size(cleanUnitLines(statement@src)) - 2);					
		}
	}
	
	return units;
}
