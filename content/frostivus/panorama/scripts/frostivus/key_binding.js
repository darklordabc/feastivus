// keep keybinding in a single file so we wont ruin the panorama when reloading
function WrapFunction(name) {
    return function() {
        Game[name]();
    };
}

Game.EmptyCallback = function() {
	// an empty callback
};

(function() {
	Game.AddCommand( "+KeyboardCommand_Up", WrapFunction("KeyboardCommand_Up"), "", 0 );
	Game.AddCommand( "+KeyboardCommand_Left", WrapFunction("KeyboardCommand_Left"), "", 0 );
	Game.AddCommand( "+KeyboardCommand_Down", WrapFunction("KeyboardCommand_Down"), "", 0 );
	Game.AddCommand( "+KeyboardCommand_Right", WrapFunction("KeyboardCommand_Right"), "", 0 );

	Game.AddCommand( "-KeyboardCommand_Up", WrapFunction("KeyboardCommand_Up_End"), "", 0 );
	Game.AddCommand( "-KeyboardCommand_Left", WrapFunction("KeyboardCommand_Left_End"), "", 0 );
	Game.AddCommand( "-KeyboardCommand_Down", WrapFunction("KeyboardCommand_Down_End"), "", 0 );
	Game.AddCommand( "-KeyboardCommand_Right", WrapFunction("KeyboardCommand_Right_End"), "", 0 );

	Game.AddCommand( "+CTRLKey", WrapFunction("OnCtrlKeyDown"), "", 0 );
	Game.AddCommand( "-CTRLKey", WrapFunction("EmptyCallback"), "", 0 );
	Game.AddCommand( "+SpaceKey", WrapFunction("OnSpaceKeyDown"), "", 0 );
	Game.AddCommand( "-SpaceKey", WrapFunction("EmptyCallback"), "", 0 );
})();
