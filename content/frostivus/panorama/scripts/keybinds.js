// I'll do custom keybind shit from here eventually.jpg

GameUI.Keybinds = {}

var DIR_UP = 0;
var DIR_LEFT = 1;
var DIR_DOWN = 2;
var DIR_RIGHT = 3;

function OnUpKeyPress()    {KeyDownEvent(DIR_UP);}
function OnLeftKeyPress()  {KeyDownEvent(DIR_LEFT);}
function OnDownKeyPress()  {KeyDownEvent(DIR_DOWN);}
function OnRightKeyPress() {KeyDownEvent(DIR_RIGHT);}

function OnUpKeyRelease()    {KeyUpEvent(DIR_UP);}
function OnLeftKeyRelease()  {KeyUpEvent(DIR_LEFT);}
function OnDownKeyRelease()  {KeyUpEvent(DIR_DOWN);}
function OnRightKeyRelease() {KeyUpEvent(DIR_RIGHT);}

function KeyDownEvent(dir) {
	GameEvents.SendCustomGameEventToServer('keyDown', {dir: '' + dir});
}

function KeyUpEvent(dir) {
	GameEvents.SendCustomGameEventToServer('keyUp', {dir: '' + dir});
}

(function() {
	Game.AddCommand( "+WKey", OnUpKeyPress, "", 0 );
	Game.AddCommand( "-WKey", OnUpKeyRelease, "", 0 );
	Game.AddCommand( "+AKey", OnLeftKeyPress, "", 0 );
	Game.AddCommand( "-AKey", OnLeftKeyRelease, "", 0 );
	Game.AddCommand( "+SKey", OnDownKeyPress, "", 0 );
	Game.AddCommand( "-SKey", OnDownKeyRelease, "", 0 );
	Game.AddCommand( "+DKey", OnRightKeyPress, "", 0 );
	Game.AddCommand( "-DKey", OnRightKeyRelease, "", 0 );
})();
