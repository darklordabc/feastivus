Game.KeyboardCommand_Up = function() {
	GameEvents.SendCustomGameEventToServer("pkd", {c:"W"}) // pkd short for player key down
};

Game.KeyboardCommand_Up_End = function() {
	GameEvents.SendCustomGameEventToServer("pku", {c:"W"})
};

Game.KeyboardCommand_Left = function() {
	GameEvents.SendCustomGameEventToServer("pkd", {c:"A"})
};

Game.KeyboardCommand_Left_End = function() {
	GameEvents.SendCustomGameEventToServer("pku", {c:"A"})
};

Game.KeyboardCommand_Down = function() {

	GameEvents.SendCustomGameEventToServer("pkd", {c:"S"})
};

Game.KeyboardCommand_Down_End = function() {
	GameEvents.SendCustomGameEventToServer("pku", {c:"S"})
};

Game.KeyboardCommand_Right = function() {
	GameEvents.SendCustomGameEventToServer("pkd", {c:"D"})
};
Game.KeyboardCommand_Right_End = function() {
	GameEvents.SendCustomGameEventToServer("pku", {c:"D"})
};

Game.OnCtrlKeyDown = function() {
	GameEvents.SendCustomGameEventToServer("pkd", {c:"ctrl"})	
};

Game.OnSpaceKeyDown = function() {
	GameEvents.SendCustomGameEventToServer("pkd", {c:"space"})
};

var m_CurrentGreevil;
var m_ExtraGreevil;
var m_LocalParticleIndex;

function OnPlayerHaveAnotherGreevil(args) {
	m_ExtraGreevil = args.entindex;
}

function IndicateCurrentGreevil() {

	if (m_CurrentGreevil == null) {
		m_CurrentGreevil = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
		if (m_CurrentGreevil == null) {
			$.Schedule(1/30, IndicateCurrentGreevil);
			return;
		}
	}

	// show particle on current player
	if (m_LocalParticleIndex == null) {
		m_LocalParticleIndex = Particles.CreateParticle( "particles/generic/current_greevil_indicator.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, m_CurrentGreevil);
	}

	Particles.SetParticleControlEnt(m_LocalParticleIndex, 0, m_CurrentGreevil, ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, "follow_origin",Entities.GetAbsOrigin(m_CurrentGreevil), true)

	$.Schedule(1/30, IndicateCurrentGreevil);
}


Game.SwapGreevil = function() {
	if (m_CurrentGreevil == m_ExtraGreevil) {
		m_CurrentGreevil = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
	} else {
		m_CurrentGreevil = m_ExtraGreevil;
	}
	GameUI.SelectUnit(m_CurrentGreevil, false);
}

var m_ControlMethod = 0;

Game.PlayerSetController = function(option) {
	if (option === "keyboard"){
		m_ControlMethod = 1;
	}else{
		m_ControlMethod = 0;
	}
};

(function() {
	GameUI.SetMouseCallback( function( eventName, arg ) {
		var nMouseButton = arg
		var CONSUME_EVENT = true;
		var CONTINUE_PROCESSING_EVENT = false;
		if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
			return CONTINUE_PROCESSING_EVENT;

		// consume right click when using keyboard controller
		if ( arg === 1 && m_ControlMethod === 1 ) { // RMB
			if (eventName === "pressed") { // click
				return CONSUME_EVENT; 
			}
			if (eventName == "doublepressed") { // double click
				return CONSUME_EVENT;
			}
		}
		return CONTINUE_PROCESSING_EVENT;
	})

	IndicateCurrentGreevil();
	GameEvents.Subscribe("player_extra_greevil", OnPlayerHaveAnotherGreevil);
})();