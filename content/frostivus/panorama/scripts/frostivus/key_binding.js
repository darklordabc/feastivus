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
	Game.AddCommand( "+WKey", WrapFunction("OnWKeyDown"), "", 0 );
	Game.AddCommand( "+AKey", WrapFunction("OnAKeyDown"), "", 0 );
	Game.AddCommand( "+SKey", WrapFunction("OnSKeyDown"), "", 0 );
	Game.AddCommand( "+DKey", WrapFunction("OnDKeyDown"), "", 0 );

	Game.AddCommand( "-WKey", WrapFunction("OnWKeyUp"), "", 0 );
	Game.AddCommand( "-AKey", WrapFunction("OnAKeyUp"), "", 0 );
	Game.AddCommand( "-SKey", WrapFunction("OnSKeyUp"), "", 0 );
	Game.AddCommand( "-DKey", WrapFunction("OnDKeyUp"), "", 0 );

	Game.AddCommand( "+CTRLKey", WrapFunction("OnCtrlKeyDown"), "", 0 );
	Game.AddCommand( "-CTRLKey", WrapFunction("EmptyCallback"), "", 0 );
	Game.AddCommand( "+SpaceKey", WrapFunction("OnSpaceKeyDown"), "", 0 );
	Game.AddCommand( "-SpaceKey", WrapFunction("EmptyCallback"), "", 0 );
})();
