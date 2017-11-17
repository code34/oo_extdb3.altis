	call compile preprocessFileLineNumbers "oo_extdb3.sqf";

	sleep 2;

	/* 
		SQL CUSTOM Example
		Call the query getAll

		private _extdb3 = "new" call OO_extDB3;
		["setDatabaseConfigName", "Database"] call _extdb3;
		["setDatabaseName", "extdb3"] call _extdb3;
		["setIniFile", "test.ini"] call _extdb3;
		["setDatabaseProtocol", "SQL_CUSTOM"] call _extdb3;
		_result = "connect" call _extdb3;
		private _query = ["getAll", []];
		_result = ["executeQuery", _query] call _extdb3;
		hintc format ["%1", _result];
	*/

	/*
		SQL CLASSIC QUERY

		private _extdb3 = "new" call OO_extDB3;
		["setDatabaseConfigName", "Database"] call _extdb3;
		["setDatabaseName", "extdb3"] call _extdb3;
		["setDatabaseProtocol", "SQL"] call _extdb3;
		_result = "connect" call _extdb3;
		private _query = "SELECT * FROM test LIMIT 10;";
		_result = ["executeQuery", _query] call _extdb3;
		hintc format ["%1", _result];
	*/

