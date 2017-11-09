	/*
	Author: code34 nicolas_boiteux@yahoo.fr
	Copyright (C) 2017-2018 Nicolas BOITEUX

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
		PRIVATE VARIABLE("string","databaseconfigname");
		PRIVATE VARIABLE("string","databaseprotocol");

		PUBLIC FUNCTION("","constructor") { 
			DEBUG(#, "OO_EXTDB3::constructor")

		};

		PUBLIC FUNCTION("","getVersion") {
			DEBUG(#, "OO_EXTDB3::getVersion")
			"extDB3" callExtension "9:VERSION";
		};

		PUBLIC FUNCTION("string", "setDatabaseConfigName") {
			DEBUG(#, "OO_EXTDB3::setDatabaseConfigName")
			MEMBER("databaseconfigname", _this);
		};

		PUBLIC FUNCTION("string", "setDatabaseName") {
			DEBUG(#, "OO_EXTDB3::setDatabaseName")
			MEMBER("databasename", _this);
		};

		/*
			Protocol type SQL | SQL_CUSTOM
		*/
		PUBLIC FUNCTION("string", "setDatabaseProtocol") {
			DEBUG(#, "OO_EXTDB3::setDatabaseProtocol")
			MEMBER("databaseprotocol", _this);
		};

		/*
			_this select 0 : password to lock
			return [0, blabla]
		*/
		PUBLIC FUNCTION("string", "lock") {
			DEBUG(#, "OO_EXTDB3::lock")
			call compile ("extDB3" callExtension (format ["9:LOCK:%1", _this]));
		};


		/*
			return [0, "blabla"]
		*/
		PUBLIC FUNCTION("", "lock") {
			DEBUG(#, "OO_EXTDB3::lock")
			call compile ("extDB3" callExtension "9:LOCK");
		};

		/*
			_this select 0 : password to unlock
			return [1]
		*/
		PUBLIC FUNCTION("string", "unlock") {
			DEBUG(#, "OO_EXTDB3::unlock")
			call compile ("extDB3" callExtension (format ["9:UNLOCK:%1", _this]));
		};

		/*
			return [1]
		*/
		PUBLIC FUNCTION("", "unlock") {
			DEBUG(#, "OO_EXTDB3::unlock")
			call compile ("extDB3" callExtension "9:UNLOCK");
		};

		/*
			return
			[0] // extension is unlocked.  
			[1] // extension is locked.
		*/
		PUBLIC FUNCTION("", "lockStatus") {
			DEBUG(#, "OO_EXTDB3::lockStatus")
			call compile ("extDB3" callExtension "9:LOCK_STATUS");
		};


		/*
			return [0]
			return [1] if success
		*/
		PUBLIC FUNCTION("", "reset") {
			DEBUG(#, "OO_EXTDB3::reset")
			call compile ("extDB3" callExtension "9:RESET");
		};

		/*
			return array
		*/
		PUBLIC FUNCTION("", "getLocalTime") {
			DEBUG(#, "OO_EXTDB3::getLocalTime")
			call compile ("extDB3" callExtension "9:LOCAL_TIME");
		};

		/*
			param Local Time + x Hours
			return array
		*/
		PUBLIC FUNCTION("scalar", "getLocalTime") {
			DEBUG(#, "OO_EXTDB3::getLocalTime_scalar")
			call compile ("extDB3" callExtension (format["9:LOCAL_TIME:%1", _this]));
		};

		/*
			years and months are not used
			param Local Time [0,0, +x Days, +x Hours, +x Minutes, +x Seconds]
			return [] if error
		*/
		PUBLIC FUNCTION("array", "getLocalTime") {
			DEBUG(#, "OO_EXTDB3::getLocalTime_array")
			if!(count _this isEqualTo 6) exitWith {[];};
			private _result = call compile ("extDB3" callExtension (format["9:LOCAL_TIME:%1", _this]));
			if((_result select 0) isEqualTo 1) then {
				_result = _result select 1;
			} else {
				_result = [];
			};
			_result;
		};

		/*
			return array
		*/
		PUBLIC FUNCTION("", "getUtcTime") {
			DEBUG(#, "OO_EXTDB3::getUtcTime")
			call compile ("extDB3" callExtension "9:UTC_TIME");
		};

		/*
			param Utc Time + x Hours
			return array
		*/
		PUBLIC FUNCTION("scalar", "getUtcTime") {
			DEBUG(#, "OO_EXTDB3::getUtcTime_scalar")
			call compile ("extDB3" callExtension (format["9:UTC_TIME:%1", _this]));
		};

		/*
			years and months are not used
			param Utc Time [0,0, +x Days, +x Hours, +x Minutes, +x Seconds]
			return [] if error
		*/
		PUBLIC FUNCTION("array", "getUtcTime") {
			DEBUG(#, "OO_EXTDB3::getUtcTime_array")
			if!((count _this) isEqualTo 6) exitWith { []; };
			private _result = call compile ("extDB3" callExtension (format["9:UTC_TIME:%1", _this]));
			if((_result select 0) isEqualTo 1) then {
				_result = _result select 1;
			} else {
				_result = [];
			};
			_result;
		};

		/*
			return array
		*/
		PUBLIC FUNCTION("", "getUtcTime") {
			DEBUG(#, "OO_EXTDB3::getUtcTime")
			call compile ("extDB3" callExtension "9:UTC_TIME");
		};

		/*
			params : "SECONDS", "MINUTES", "HOURS"
			return scalar
		*/
		PUBLIC FUNCTION("string", "getUptime") {
			DEBUG(#, "OO_EXTDB3::getUptime")
			if!(_this in ["SECONDS", "MINUTES", "HOURS"]) exitWith {0;};
			call compile ("extDB3" callExtension (format["9:UPTIME:%1", _this]));
		};

		/*
			years and months are not used
			param  [[0,0, Days, Hours, Minutes, Seconds], [+x Days, +x Hours, +x Minutes, +x Seconds]]
			return [] if error
		*/
		PUBLIC FUNCTION("array", "addDate") {
			DEBUG(#, "OO_EXTDB3::addDate")
			if!(count _this isEqualTo 2) exitWith { []; };
			private _result = call compile ("extDB3" callExtension format["9:DATEADD:%1:%2", _this select 0, _this select 1]);
			if((_result select 0) isEqualTo 1) then {
				_result = _result select 1;
			} else {
				_result = [];
			};
			_result;	
		};

		/*
			return scalar
		*/
		PUBLIC FUNCTION("", "getOutPutSize") {
			call compile ("extDB3" callExtension "9:OUTPUTSIZE");
		};

		PUBLIC FUNCTION("","deconstructor") { 
			DEBUG(#, "OO_EXTDB3::deconstructor")
			DELETE_VARIABLE("databasename");
			DELETE_VARIABLE("databaseconfigname");
		};
	ENDCLASS;