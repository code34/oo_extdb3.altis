	call compile preprocessFileLineNumbers "oo_extdb3.sqf";

	sleep 2;

	private _extdb3 = "new" call OO_extDB3;
	private _result = "getVersion" call _extdb3;
	hintc format ["result : %1", _result];

	


		



