function RemoveLeftBlank() {
	$.GetContextPanel().GetParent().style.marginLeft = "0px";
}

var g_PlayersPanel = [];
var g_PlayerIDPanelMapper = {};
var g_UnreadyPlayers = [];
var b_CountingDown = false;
function OnClickReadyButton() {

}

function OnRockAndRoll() {
	// dont allow start if there are un-ready players
	if (g_UnreadyPlayers.length > 0) return;

	if (b_CountingDown){
		OnCancelStart();
		return;
	}

	b_CountingDown = true;
	CountDownAndStart();
	GameEvents.SendCustomGameEventToServer("set_play_tutorial", {
		value: false
	});

	// disable the start tutorial button
	$("#button_start_tutorial").enabled = false;
	// set art to cancel
	$("#rock_and_roll_button_bg").SetImage("file://{resources}/images/custom_game/welcome_screen/cancel_button.psd");
}

function OnStartTutorial() {
	// dont allow start if there are un-ready players
	if (g_UnreadyPlayers.length > 0) return;

	if (b_CountingDown){
		OnCancelStart();
		return;
	}

	b_CountingDown = true;
	CountDownAndStart();
	GameEvents.SendCustomGameEventToServer("set_play_tutorial", {
		value: true
	});

	// disable the start button
	$("#button_rock_and_roll").enabled= false;
	// switch bg to cancel
	$("#start_tutorial_button_bg").SetImage("file://{resources}/images/custom_game/welcome_screen/cancel_button.psd");
}

function OnCancelStart() {
	// enable buttons
	$("#button_rock_and_roll").enabled= true;
	$("#button_start_tutorial").enabled = true;
	$("#rock_and_roll_button_bg").SetImage("file://{resources}/images/custom_game/welcome_screen/start_button.psd");
	$("#start_tutorial_button_bg").SetImage("file://{resources}/images/custom_game/welcome_screen/start_tutorial_button.psd");

	// reset timer to 30
	Game.SetRemainingSetupTime(30);
}

function CountDownAndStart() {
	// Disable the auto start count down
	Game.SetAutoLaunchEnabled( false );
	// Set the remaining time before the game starts
	Game.SetRemainingSetupTime( 4 ); 
}

// we leave the parent parameter in case of versus mode
function FindOrCreatePanelForPlayer(playerID, parent) {
	// search the player panel list for the player id
	for (var i==0; i < g_PlayersPanel.length; ++i) {
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
	var playerInfo = Game.GetPlayerInfo( playerId );
	newPlayerPanel.FindChildTraverse("player_name").steamid = playerInfo.player_steamid;
	newPlayerPanel.FindChildTraverse("player_portrait").steamid = playerInfo.player_steamid;

	// highlight local player card
	var localPlayerInfo = Game.GetLocalPlayerInfo();
	if (localPlayerInfo) {
		$.Msg("Local player info -> ",localPlayerInfo);
		// if (localPlayerInfo.player_id)
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
	for (var i == 0; i < teamPlayers.length; ++i) {
		FindOrCreatePanelForPlayer(teamPlayers[i], teamPanel)
	}
}

function UpdateTimer() {
	var gameTime = Game.GetGameTime();
	var transitionTime = Game.GetStateTransitionTime();

	if (transitionTime >= 0) {
		
	}
}

// <snippet name="PlayerCard">
// 			<Panel class="PlayerCardRoot">
// 				<Panel class="PlayerCardBackground" />

// 				<!-- player card content -->
// 				<Image class="PlayerHeroArt" id="hero_art" src="file://{resources}/images/custom_game/welcome_screen/temp_hero_art.psd"/>
// 				<DOTAUserName class="PlayerName" id="player_name" steamid="local" />
// 				<DOTAAvatarImage class="PlayerPortrait" id="player_portrait" steamid="local" />
// 				<Image id="ready_state" />

// 				<!-- @todo other message to display in bottom section -->

// 				<Panel class="PlayerCardOverlay" />
// 			</Panel>
// 		</snippet>

(function() {
	RemoveLeftBlank();
	// auto assign player to teams
	Game.AutoAssignPlayersToTeams();
})();