(function () {
	var won = Game.GetGameWinner() == 2;
	if (won) {
		$("#Image").SetImage("file://{resources}/images/custom_game/ui/won.png");
		$("#ResultLabel").text = $.Localize("#win");

		Game.EmitSound("frostivus_ui_select");
	} else {
		Game.EmitSound("custom_sound.failed");
	}
})();