function RemoveLeftBlank() {
	$.GetContextPanel().GetParent().style.marginLeft = "0px";
}

var g_PlayersPanel = [];
var g_PlayerIDPanelMapper = {};
var g_UnreadyPlayers = [];
var b_CountingDown = false;
var b_HasHostPrivileges = false;

function CheckHostPrivileges() {
	var playerInfo = Game.GetLocalPlayerInfo();
	if ( !playerInfo )
		return;
	b_HasHostPrivileges = playerInfo.player_has_host_privileges;

	$.GetContextPanel().SetHasClass( "player_has_host_privileges", playerInfo.player_has_host_privileges );

	// if (b_HasHostPrivileges)
	// 	$("#label_button_start_ready").text = $.Localize("#ready");
}

function IsAllReady() {
	// @fixme
	return true
}

function OnClickReadyOrStart() {
	// if player has host privileges, start the game
	// the players dont have host privileges just need to wait for it to start atm
	// just leave the hats feature later
	if (b_HasHostPrivileges && IsAllReady()) {
		// CountDownAndStart();
	}else{
		// GameEvents.SendCustomGameEventToServer('player_ready', {})
	}
}

// function OnClickReadyButton() {
// 	// player id will be attached by default in game events
// 	// @todo, implement in lua for player ready.
// 	$.Msg("player ready!")
// 	GameEvents.SendCustomGameEventToServer("player_ready", {})
// }

// function OnRockAndRoll() {
// 	// dont allow start if there are un-ready players
// 	// if (g_UnreadyPlayers.length > 0) return;

// 	if (b_CountingDown){
// 		OnCancelStart();
// 		return;
// 	}

// 	b_CountingDown = true;
// 	CountDownAndStart();
// 	GameEvents.SendCustomGameEventToServer("set_play_tutorial", {
// 		value: false
// 	});

// 	// disable the start tutorial button
// 	// $("#button_start_tutorial").enabled = false;
// 	// set art to cancel
// 	// $("#rock_and_roll_button_bg").SetImage("file://{resources}/images/custom_game/welcome_screen/cancel_button.psd");
// }

// function OnStartTutorial() {
// 	// dont allow start if there are un-ready players
// 	if (g_UnreadyPlayers.length > 0) return;

// 	if (b_CountingDown){
// 		OnCancelStart();
// 		return;
// 	}

// 	b_CountingDown = true;
// 	CountDownAndStart();
// 	GameEvents.SendCustomGameEventToServer("set_play_tutorial", {
// 		value: true
// 	});

// 	// disable the start button
// 	$("#button_rock_and_roll").enabled= false;
// 	// switch bg to cancel
// 	$("#start_tutorial_button_bg").SetImage("file://{resources}/images/custom_game/welcome_screen/cancel_button.psd");
// }

// function OnCancelStart() {
// 	// enable buttons
// 	$("#button_rock_and_roll").enabled= true;
// 	$("#button_start_tutorial").enabled = true;
// 	$("#rock_and_roll_button_bg").SetImage("file://{resources}/images/custom_game/welcome_screen/start_button.psd");
// 	$("#start_tutorial_button_bg").SetImage("file://{resources}/images/custom_game/welcome_screen/start_tutorial_button.psd");

// 	// reset timer to 30
// 	Game.SetRemainingSetupTime(30);
// }

function CountDownAndStart() {
	// Disable the auto start count down
	Game.SetAutoLaunchEnabled( false );
	// Set the remaining time before the game starts
	Game.SetRemainingSetupTime(4);
}

// we leave the parent parameter in case of versus mode
function FindOrCreatePanelForPlayer(playerID, parent) {
	// search the player panel list for the player id
	for (var i = 0; i < g_PlayersPanel.length; ++i) {
		var playerPanel = g_PlayersPanel[i];
		if (g_PlayerIDPanelMapper[playerID] == playerPanel) {
			playerPanel.SetParent(parent);
			return playerPanel;
		}
	}

	// create a new player card
	var newPlayerPanel = $.CreatePanel("Panel", parent, "player_root");
	g_PlayerIDPanelMapper[playerID] = newPlayerPanel;
	newPlayerPanel.BLoadLayoutSnippet("PlayerCard");

	// setup username and avatar
	var playerInfo = Game.GetPlayerInfo( playerID );
	newPlayerPanel.FindChildTraverse("player_name").steamid = playerInfo.player_steamid;
	newPlayerPanel.FindChildTraverse("player_portrait").steamid = playerInfo.player_steamid;

	// highlight local player card
	var localPlayerInfo = Game.GetLocalPlayerInfo();
	if (localPlayerInfo) {
		if (localPlayerInfo.player_id == playerID) {
			newPlayerPanel.SetHasClass("LocalPlayer", true);
		}
	}

	// check host and show!
	$.GetContextPanel().SetHasClass("Host", localPlayerInfo.player_has_host_privileges)

	return newPlayerPanel;
}

function UpdatePlayerCards(teamid) {
	// goodguys by default
	var teamPanel = $("#player_card_panel_goodguys");
	if (teamid == 2) {
	}else if(teamid == 3){
		teamPanel = $("#player_card_panel_badguys")
	}

	// find all players in team
	var teamPlayers = Game.GetPlayerIDsOnTeam(teamid);

	// remove the current players
	teamPanel.RemoveAndDeleteChildren();

	// create them
	for (var i = 0; i < teamPlayers.length; ++i) {
		// $.Msg("creating panel for player", teamPlayers[i])
		FindOrCreatePanelForPlayer(teamPlayers[i], teamPanel)
	}
}

function UpdateTimer() {
	var gameTime = Game.GetGameTime();
	var transitionTime = Game.GetStateTransitionTime();
	
	if (transitionTime >= 0) {
		var timeToTransition = transitionTime - gameTime;
		var mins = Math.floor(timeToTransition / 60);
		var secs = Math.floor(timeToTransition - mins * 60);
		var mins1 = Math.floor(mins / 10);
		var mins2 = mins - mins1 * 10;
		var secs1 = Math.floor(secs / 10);
		var secs2 = secs - secs1 * 10;
		$("#count_down_mins_1").style.backgroundPosition = -64 * mins1 + "px";
		$("#count_down_mins_2").style.backgroundPosition = -64 * mins2 + "px";
		$("#count_down_secs_1").style.backgroundPosition = -64 * secs1 + "px";
		$("#count_down_secs_2").style.backgroundPosition = -64 * secs2 + "px";
	}else {
		// set all digits to 00:00
		$("#count_down_mins_1").style.backgroundPosition = "0px";
		$("#count_down_mins_2").style.backgroundPosition = "0px";
		$("#count_down_secs_1").style.backgroundPosition = "0px";
		$("#count_down_secs_2").style.backgroundPosition = "0px";
	}
	$.Schedule(0.1, UpdateTimer);
}

function OnTeamPlayerListChanged() {
	UpdatePlayerCards(2);
}

function OnPlayerSelectedTeam() {
	UpdatePlayerCards(2);
}

function OnGameRulesStateChanged() {
	var newState = Game.GetState()
	$.Msg("game state has changed to",newState);
}

(function() {
	// i dont know why there is a blank section at left
	// maybe we should remove this later
	RemoveLeftBlank();

	// auto assign player to teams
	Game.AutoAssignPlayersToTeams();

	UpdateTimer();

	// debug freeze the count down timer
	// Game.SetRemainingSetupTime(30); 
	Game.SetRemainingSetupTime(4); 

	// Register a listener for the event which is brodcast when the team assignment of a player is actually assigned
	$.RegisterForUnhandledEvent( "DOTAGame_TeamPlayerListChanged", OnTeamPlayerListChanged );

	// Register a listener for the event which is broadcast whenever a player attempts to pick a team
	$.RegisterForUnhandledEvent( "DOTAGame_PlayerSelectedCustomTeam", OnPlayerSelectedTeam );

	GameEvents.Subscribe("dota_game_rules_state_change", OnGameRulesStateChanged);

	CheckHostPrivileges();
})();