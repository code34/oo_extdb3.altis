	/*
	Author: code34 nicolas_boiteux@yahoo.fr
	Copyright (C) 2014-2016 Nicolas BOITEUX

	CLASS OO_EXTDB3
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>. 
	*/

	#include "oop.h"

	CLASS("OO_EXTDB3")
		PRIVATE VARIABLE("string","databasename");

		PUBLIC FUNCTION("","constructor") { 
			DEBUG(#, "OO_EXTDB3::constructor")

		};

		PUBLIC FUNCTION("","getVersion") {
			DEBUG(#, "OO_EXTDB3::getVersion")
			"extDB3" callExtension "9:VERSION";
		};



		PUBLIC FUNCTION("","deconstructor") { 
			DEBUG(#, "OO_EXTDB3::deconstructor")
			DELETE_VARIABLE("databasename");
		};
	ENDCLASS;