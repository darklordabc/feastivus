(function () {
	var won = Game.GetGameWinner() == 2;
	if (won) {
		
	} else {
		Game.EmitSound("custom_sound.failed");
	}
})();