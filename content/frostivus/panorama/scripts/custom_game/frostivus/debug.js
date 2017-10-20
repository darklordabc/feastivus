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

function ToggleTrackingCamera() {
	var portraitUnit = Players.GetLocalPlayerPortraitUnit();
	GameEvents.SendCustomGameEventToServer('toggle_tracking_camera', {entindex: portraitUnit})
}

var m_PortraitUnit;

function DetectCurrentUnit() {
	var portraitUnit = Players.GetLocalPlayerPortraitUnit();
	if (portraitUnit == null || portraitUnit < 0) $.Schedule(0.03, DetectCurrentUnit);
	if (portraitUnit != m_PortraitUnit) {
		m_PortraitUnit = portraitUnit;
		GameEvents.SendCustomGameEventToServer('debug_update_current_unit', {entindex: portraitUnit});
	}
	$.Schedule(0.03, DetectCurrentUnit);
}

(function(){
	if (Game.IsInToolsMode()) {
		$.GetContextPanel().RemoveClass('Hidden');
		DetectCurrentUnit();
	}
})();