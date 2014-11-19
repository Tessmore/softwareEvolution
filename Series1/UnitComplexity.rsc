module UnitComplexity

import IO;
import ListRelation;
import List;

import lang::java::jdt::m3::AST;

/* In the paper they assign a risk level to each unit, which allows LOC to be 
  grouped in risk categories. */

str non 	   = "no risk";
str moderate   = "moderate risk";
str high	   = "high risk";
str untestable = "untestable, very high risk";

bool noRisk(int CC) 	  = CC <= 10;
bool moderateRisk(int CC) = CC <= 20;
bool highRisk(int CC)	  = CC <= 50;


map[str, value] projectComplexity(set[Declaration] asts) {
	map[str, num] result = (
		non		   : 0,
		moderate   : 0,
		high	   : 0, 
		untestable : 0
	);

	// Visit all units (methods and constructors)	
	visit(asts) {
		case \method(_, _, _, _, statement) : {
			risk = unitRisk(statement);	
			result[risk[0]] += risk[1];
		}
		
		case \constructor(_, _, _, statement) : {
			risk = unitRisk(statement);
			result[risk[0]] += risk[1];				
		}
	}
	
	num totalUnitLOC = sum([result[i] | i <- result]);

	// Create % of LOC per category for scoring
	result = (k : result[k]/totalUnitLOC | k <- result);
	
	return result + ("score" : complexityScore(result));
}


tuple[str, int] unitRisk(statement) {
	LOC  = statement@src.end.line - statement@src.begin.line;
	CC   = calculateCC(statement);			
	
	return <calculateRisk(CC), LOC>;		
}


int calculateCC(Statement s) {
	int result = 1;
	
	visit (s) {
		case \if(_,_) 			 : result += 1;
		case \if(_,_,_) 		 : result += 1;
		
		case \case(_) 	    	 : result += 1;
		
		case \do(_,_) 	         : result += 1;
		case \while(_,_) 	     : result += 1;
		
		case \for(_,_,_) 		 : result += 1;
		case \for(_,_,_,_)  	 : result += 1;
		case foreach(_,_,_)      : result += 1;
		
		case \catch(_,_)	     : result += 1;
		
		case \conditional(_,_,_) : result += 1;
		
		case infix(_,"&&",_)	 : result += 1;
		case infix(_,"||",_)	 : result += 1;
	}
	
	return result;
}


str calculateRisk(int CC) {
	if (noRisk(CC))
		return non;
	else if (moderateRisk(CC))
		return moderate;
	else if (highRisk(CC))
		return high;
	else
		return untestable;
}

str complexityScore(map[str, num] r) {
  if 	  (r[moderate] <= .25 && r[high] < .01 && r[untestable] <  .01)
  	return "++";
  else if (r[moderate] <= .30 && r[high] < .05 && r[untestable] <  .01)
  	return "+";
  else if (r[moderate] <= .40 && r[high] < .10 && r[untestable] <  .01)
  	return "0";
  else if (r[moderate] <= .50 && r[high] < .15 && r[untestable] <= .05)
  	return "-";
  else
	return "--";
}
