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

//=============================================================================
// Mouse Click and Zoom
//=============================================================================
const ZOOM_RATE = 100;
const MAX_ZOOM = 2000;
const MIN_ZOOM = 1000;

// Other things
var TEXT_CONVERSION = 1000;
var ZOOM_INTERVAL = 0.03;
var ZOOM_JUMP = 10;
var FAST_ZOOM = 10;
var DEFAULT_ZOOM = 1500;
var CAMERA_DEFAULT_PITCH = 66

/**
 * Call this to set the zoom. Eventually, if they ever add
 * camera moving functionality from panorama, I'll make it move
 * the camera up and down so the zoom zooms in and out of the
 * what you're currently viewing instead of just vertically.
 */
function SetZoom( newZoom ) {
	GameUI.SetCameraDistance(newZoom);
	SetPitch(CAMERA_DEFAULT_PITCH);
	currZoom = newZoom;
}

function SetPitch( pitch ) {
	GameUI.SetCameraPitchMin(pitch);
	GameUI.SetCameraPitchMax(pitch);
}

var currZoom = DEFAULT_ZOOM;
var bufferedZoom = DEFAULT_ZOOM;
var locked = false;
SetZoom(DEFAULT_ZOOM);

function AdjustZoom() {
	var newZoom = currZoom;
	if (bufferedZoom > newZoom) {
		var diff = bufferedZoom - newZoom;
		if (diff < ZOOM_JUMP)
			newZoom = bufferedZoom;
		else if (diff / 10 < ZOOM_JUMP)
			newZoom += ZOOM_JUMP;
		else
			newZoom += diff / 10;
	} else if (bufferedZoom < currZoom) {
		var diff = currZoom - bufferedZoom;
		if (diff < ZOOM_JUMP)
			newZoom = bufferedZoom;
		else if (diff / 10 < ZOOM_JUMP)
			newZoom -= ZOOM_JUMP;
		else
			newZoom -= diff / 10;
	}
	
	SetZoom( newZoom );
	
	if (bufferedZoom != currZoom)
		$.Schedule(ZOOM_INTERVAL, function(){AdjustZoom();});
}

GameUI.SetMouseCallback( function( eventName, arg ) {
	const CONSUME_EVENT = true;
	const CONTINUE_PROCESSING_EVENT = false;
	
	if (eventName === "pressed" && (arg == 5 || arg == 6) ) {
		return CONSUME_EVENT;
	}
	
	if ( eventName === "wheeled" ) {
		// Disable scrolling when locked
		if ( locked )
			return CONSUME_EVENT;
		
		if ( arg < 0 && bufferedZoom < MAX_ZOOM ) { // Zoom out
			bufferedZoom += ZOOM_RATE;
		}
		else if ( arg > 0 && bufferedZoom > MIN_ZOOM ) { // Zoom in
			bufferedZoom -= ZOOM_RATE;
		}
		AdjustZoom();
		return CONSUME_EVENT;
	}
	return CONTINUE_PROCESSING_EVENT;
} );
