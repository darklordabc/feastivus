function SetController(option){
	$.Msg("Player controller has changed to -> ", option)
	GameEvents.SendCustomGameEventToServer("player_set_controller", {
		option: option
	})
	ToggleSettingPanel();

	// this method is defined in frostivus/keyboard_control.js
	// for disable right click when player set to keyboard controller
	Game.PlayerSetController(option); 
}

function ToggleSettingPanel() {
	$("#setting_panel").ToggleClass("Hidden");
}