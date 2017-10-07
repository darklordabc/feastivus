function OnPreRoundCountDown(args){
	var time = args.value
	if (time == 3){
		// ready
	}else if (time == 2) {
		// set
	}else if (time == 1) {
		// GO!
	}else if (time == 0) {
		// show count down timer
		$("#CountDownTimer").RemoveClass("Hidden");
	}
}

function OnTimer(args){
	var time = args.value
	
	var mins = Math.floor(time / 60);
	var secs = Math.floor(time - mins * 60);
	var mins1 = Math.floor(mins / 10);
	var mins2 = mins - mins1 * 10;
	var secs1 = Math.floor(secs / 10);
	var secs2 = secs - secs1 * 10;
	
	if(mins <= 0) {
		$("#CountDOwnTimer").AddClass("SecondsOnly");
	}else{
		$("#CountDOwnTimer").RemoveClass("SecondsOnly");
	}

	$("#count_down_mins_1").style.backgroundPosition = -64 * mins1 + "px";
	$("#count_down_mins_2").style.backgroundPosition = -64 * mins2 + "px";
	$("#count_down_secs_1").style.backgroundPosition = -64 * secs1 + "px";
	$("#count_down_secs_2").style.backgroundPosition = -64 * secs2 + "px";
}

}

(function(){
	GameEvents.Subscribe("pre_round_countdowm", OnPreRoundCountDown);
	GameEvents.Subscribe("round_timer", OnTimer);
})();