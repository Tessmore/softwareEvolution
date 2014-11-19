module Main

import IO;

import Util;

import Volume;
import UnitComplexity;
import UnitSize;
import Duplication;

import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;


void main() {
	loc projectLocation = |project://testDb|; 

	model = createM3FromEclipseProject(projectLocation); 
  	asts  = createAstsFromEclipseProject(projectLocation, true); 
  
	// Get comments from entire project, grouped by file  
  	map[loc, set[loc]] comments = M3CommentsByFile(model@documentation);
  
	//volume 	    = projectVolume(asts, comments);
	//duplication = projectDuplication(asts, comments, 6);
	complexity  = projectComplexity(asts);
	//unitSize    = projectUnitSize(asts);
	
	//println("Volume:\t\t<volume>");
	//println("Duplication:\t<duplication>");
	println("Complexity:\t<complexity>");
	//println("Unit size:\t<unitSize>");
	
}
