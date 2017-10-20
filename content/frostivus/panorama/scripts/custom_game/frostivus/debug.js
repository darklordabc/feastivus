function ToggleDebugPanel() {
	$("#DebugPanel").ToggleClass("Hidden")
}

function CreateExtraGreevilling() {
	GameEvents.SendCustomGameEventToServer('debug_create_greevilling', {})
}

function SetRoundTime() {
	var roundTime = $("#RoundTimeTextbox").text;
	$.Msg("setting round time to ", roundTime, " seconds.")
	GameEvents.SendCustomGameEventToServer('debug_set_round_time', {time: roundTime})
}

function JumpToRound() {
	var round = $("#RoundNoTextbox").text;
	$.Msg("jumpping to round #", round)
	GameEvents.SendCustomGameEventToServer('debug_jump_to_round', {round: round})
}

(function(){
	if (Game.IsInToolsMode()) {
		$.GetContextPanel().RemoveClass('Hidden');
	}
})();