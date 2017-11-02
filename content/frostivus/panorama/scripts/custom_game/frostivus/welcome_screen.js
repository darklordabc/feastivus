function RemoveLeftBlank() {
	$.GetContextPanel().GetParent().style.marginLeft = "0px";
}

var g_PlayersPanel = [];
var g_PlayerIDPanelMapper = {};
var g_UnreadyPlayers = [];
var b_CountingDown = false;
var b_HasHostPrivileges = false;

var m_MaterialSet = 0;

function OnChangeMaterial() {
	if (m_MaterialSet >= 8) {
		m_MaterialSet = 0;
	}else{
		m_MaterialSet += 1;
	}

	$.DispatchEvent( 'DOTAGlobalSceneSetCameraEntity', 'player_portrait_' + Players.GetLocalPlayer(), 'camera' + m_MaterialSet, 0);

	GameEvents.SendCustomGameEventToServer("player_change_hats", {
		MaterialGroup: m_MaterialSet,
	});
}

function CheckHostPrivileges() {
	var playerInfo = Game.GetLocalPlayerInfo();
	if ( !playerInfo )
		return;

	b_HasHostPrivileges = playerInfo.player_has_host_privileges;

	$.GetContextPanel().SetHasClass( "player_has_host_privileges", playerInfo.player_has_host_privileges );

	if (b_HasHostPrivileges)
		$("#label_button_start_ready").text = $.Localize("#start");
}

function IsAllReady() {
	// @fixme
	return true
}

function OnClickReadyOrStart() {
	
	if (b_CountingDown && b_HasHostPrivileges) {
		GameEvents.SendCustomGameEventToServer('host_cancel_start', {})
		return;
	}

	if (b_HasHostPrivileges && IsAllReady()) {
		CountDownAndStart();
	}else{
		GameEvents.SendCustomGameEventToServer('player_ready', {})
	}
}

function CountDownAndStart() {
	b_CountingDown = true;
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

	var id = "player_portrait_" + playerID;
	newPlayerPanel.BCreateChildren("<DOTAScenePanel id='" + id + "' particleonly='false' class='GreevilScene' map='greevils/greevil_1' camera='camera0'/> ");
	
	newPlayerPanel.FindChildTraverse(id).hittest = false;
	newPlayerPanel.MoveChildBefore(id, 'playerCardOverlay');
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

function OnPlayerHatsChanged() {
	var hatsData = CustomNetTables.GetTableValue('player_hats', 'player_hats');
	for (var playerID in hatsData) {
		
		var data = hatsData[playerID]
		$.Msg(playerID, " [HATS DATA]", data);

		// change material camera for other players
		if (playerID != Players.GetLocalPlayer()) {
			$.DispatchEvent( 'DOTAGlobalSceneSetCameraEntity', 'player_portrait_' + playerID, 'camera' + data.materialGroup, 0.2);
		}
	}
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
	Game.SetRemainingSetupTime(-1); 

	// Register a listener for the event which is brodcast when the team assignment of a player is actually assigned
	$.RegisterForUnhandledEvent( "DOTAGame_TeamPlayerListChanged", OnTeamPlayerListChanged );

	// Register a listener for the event which is broadcast whenever a player attempts to pick a team
	$.RegisterForUnhandledEvent( "DOTAGame_PlayerSelectedCustomTeam", OnPlayerSelectedTeam );

	GameEvents.Subscribe("dota_game_rules_state_change", OnGameRulesStateChanged);

	CheckHostPrivileges();

	UpdatePlayerCards(2);

	CustomNetTables.SubscribeNetTableListener("player_hats", OnPlayerHatsChanged);
})();