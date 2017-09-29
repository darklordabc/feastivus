Game.OnWKeyDown = function() {
	GameEvents.SendCustomGameEventToServer("pkd", {c:"W"}) // pkd short for player key down
};
Game.OnAKeyDown = function() {
	GameEvents.SendCustomGameEventToServer("pkd", {c:"A"})
};
Game.OnSKeyDown = function() {
	GameEvents.SendCustomGameEventToServer("pkd", {c:"S"})
};
Game.OnDKeyDown = function() {
	GameEvents.SendCustomGameEventToServer("pkd", {c:"D"})
};

Game.OnWKeyUp = function() {
	GameEvents.SendCustomGameEventToServer("pku", {c:"W"})
};
Game.OnAKeyUp = function() {
	GameEvents.SendCustomGameEventToServer("pku", {c:"A"})
};
Game.OnSKeyUp = function() {
	GameEvents.SendCustomGameEventToServer("pku", {c:"S"})
};
Game.OnDKeyUp = function() {
	GameEvents.SendCustomGameEventToServer("pku", {c:"D"})
};

// if we decide to disable right click movement, uncomment code below
// (function() {
// 	GameUI.SetMouseCallback( function( eventName, arg ) {
// 		var nMouseButton = arg
// 		var CONSUME_EVENT = true;
// 		var CONTINUE_PROCESSING_EVENT = false;

// 		$.Msg(eventName);

// 		if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
// 			return CONTINUE_PROCESSING_EVENT;

// 		if ( arg === 1 ) { // RMB
// 			if (eventName === "pressed") { // click
// 				return CONSUME_EVENT; 
// 			}
// 			if (eventName == "doublepressed") { // double click
// 				return CONSUME_EVENT;
// 			}
// 		}
// 	})
// })();