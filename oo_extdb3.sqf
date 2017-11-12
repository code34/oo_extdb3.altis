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
		PRIVATE VARIABLE("string", "inifile");
		PRIVATE VARIABLE("string", "sessionid");
		PRIVATE VARIABLE("string", "escapechar");

		PUBLIC FUNCTION("","constructor") { 
			DEBUG(#, "OO_EXTDB3::constructor")
			MEMBER("databasename", "");
			MEMBER("databaseconfigname", "");
			MEMBER("databaseprotocol", "");
			MEMBER("sessionid", "");
			MEMBER("escapechar", "TEXT");
		};

		/*
			Retrieve the DLL EXTDB3 version
			return sting version, or nil
		*/
		PUBLIC FUNCTION("","getVersion") {
			DEBUG(#, "OO_EXTDB3::getVersion")
			"extDB3" callExtension "9:VERSION";
		};

		/*
			Check if Dll is loaded
		*/
		PUBLIC FUNCTION("","isDllEnabled") {
			DEBUG(#, "OO_EXTDB3::isDllEnabled")
			private _result = "extDB3" callExtension "9:VERSION";	
			if(isNil "_result") exitWith { false;};
			true;
		};

		PUBLIC FUNCTION("string", "setEscapeChar") {
			DEBUG(#, "OO_EXTDB3::setEscapeChar")
			MEMBER("escapechar", _this);
		};

		PUBLIC FUNCTION("string", "setSessionId") {
			DEBUG(#, "OO_EXTDB3::setSessionId")
			MEMBER("sessionid", _this);
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
			Protocol type LOG | SQL | SQL_CUSTOM
		*/
		PUBLIC FUNCTION("string", "setDatabaseProtocol") {
			DEBUG(#, "OO_EXTDB3::setDatabaseProtocol")
			if!(_this in ["LOG", "SQL", "SQL_CUSTOM"]) exitWith { false;};
			MEMBER("databaseprotocol", _this);
		};

		PUBLIC FUNCTION("string", "setIniFile") {
			DEBUG(#, "OO_EXTDB3::setIniFile")
			MEMBER("inifile", _this);
		};

		/*
			Initialize connexion to target database
			check if connexion is already existing if not create a new one
			return true if connected, false if not
		*/
		PUBLIC FUNCTION("", "connect") {
			DEBUG(#, "OO_EXTDB3::connect")
			private _return = false;	
			private _result = call compile ("extDB3" callExtension format["9:ADD_DATABASE:%1:%2", MEMBER("databaseconfigname", nil), MEMBER("databasename", nil)]);

			if !(isNil "_result") then {
				if ((_result select 0) isEqualTo 1) then {
					_return = MEMBER("testConnexion", nil);
				}else{
					if(tolower(_result select 1) isEqualTo "already connected to database") then { 	_return = MEMBER("testConnexion", nil); } ;
				};
			};
			_return;
		};


		/*
			Initialize the target protocol SQL/SQL_CUSTOM/LOG
			Test the remote connexion to database
			return: true if its ok, false if ko
		*/
		PRIVATE FUNCTION("", "testConnexion") {
			DEBUG(#, "OO_EXTDB3::testConnexion")
			private _return = false;
			private _result = [];
			switch (MEMBER("databaseprotocol", nil)) do {
				case "SQL" : { 
					_result = call compile ("extDB3" callExtension format ["9:ADD_DATABASE_PROTOCOL:%1:SQL:SQL:%2", MEMBER("databasename", nil), MEMBER("escapechar",nil)]);
				};
				case "SQL_CUSTOM" : {
					_result = call compile ("extDB3" callExtension format ["9:ADD_DATABASE_PROTOCOL:%1:SQL_CUSTOM:SQL:%2", MEMBER("databasename", nil), MEMBER("inifile", nil)]);
				};
				default {
					_result = call compile ("extDB3" callExtension format ["9:ADD_DATABASE_PROTOCOL:%1:LOG:SQL:TEXT", MEMBER("databasename", nil)]);
				};
			};
			if !(isNil "_result") then {
				if ((_result select 0) isEqualTo 1) then { _return = true; };
			};
			_return;
		};


		/*
			Execute SQL query or Prepared Statement
			Parameter: array
				_this select 0 : string - name of preparered statement or sql query
				_this select 1 : any - return default value if nothing is found in db or error happen

			return : value from db or default value
		*/		
		PUBLIC FUNCTION("array", "executeQuery") {
			DEBUG(#, "OO_EXTDB3::executeQuery")
			private _query = param [0, "", [""]];
			private _defaultreturn = param [1, "", ["", true, 0, []]];
			private _result = _defaultreturn;
			private _mode = 0;
			private _key = call compile ("extDB3" callExtension format["0:SQL:%1", _query]);
			private _loop = 0;
			private _pipe = "";

			if((_key select 0) isEqualTo 2) then {_mode = 2;};
			switch(_mode) do {
				case 0 : { _result = _key; };
				case 2 : {
					_loop = true;
					while { _loop } do {
						_result = "extDB3" callExtension format["4:%1", _key select 1];
						switch (true) do {
							case (_result isEqualTo "[3]") : { uiSleep 0.1; };
							case (_result isEqualTo "[5]") : {
								_pipe = "go";
								_result = "";
								while{ !(_pipe isEqualTo "") } do {
									_pipe = "extDB3" callExtension format["5:%1", _key select 1];
									_result = _result + _pipe;
								};
								_loop= false;
							};
							default {_loop = false;};
						};
					};
					_result = call compile _result;
					if(isnil "_result") then { 
						_result = [0, "OO_EXTDB3: Return value is not compatible with SQF"];
					};
				};
				default { _result = [0, "OO_EXTDB3: Mode is not compatible"];	};
			};
			if ((_result select 0) isEqualTo 0) then { _result = [0, _defaultreturn]; };
			_result select 1;
		};

		/*
			A string mapper
			return empty string
		*/
		PUBLIC FUNCTION("string", "executeQuery") {
			DEBUG(#, "OO_EXTDB3::executeQuery_string")
			private _array = [_this, ""];
			MEMBER("executeQuery", _array);
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
			DELETE_VARIABLE("databaseprotocol");
			DELETE_VARIABLE("inifile");
			DELETE_VARIABLE("sessionid");
			DELETE_VARIABLE("escapechar");
		};
	ENDCLASS;