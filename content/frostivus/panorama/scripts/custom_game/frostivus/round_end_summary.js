// CustomGameEventManager:Send_ServerToAllClients('show_round_end_summary',{
// 		Stars = stars,
// 		FinishedOrdersCount = table.count(self.vFinishedOrders),
// 		UnFinishedOrdersCount = table.count(self.vPendingOrders),
// 	})

function ShowRoundEndSummary(args) {
	var stars = args.Stars;
	var finishedOrdersCount = args.FinishedOrdersCount;
	var unFinishedOrdersCount = args.UnFinishedOrdersCount;
	var allOrders = finishedOrdersCount + unFinishedOrdersCount;

	var nScoreOrdersDelivered = args.ScoreOrdersDelivered;
	var nScoreSpeedBonus = args.ScoreSpeedBonus;

	var summary_panel = $("#round_end_summary");

	// $("#finished_orders_count").text = finishedOrdersCount + "/" + allOrders;

	$("#score_orders_delivered_num").text = nScoreOrdersDelivered;
	$("#score_speed_bonus_num").text = nScoreSpeedBonus;
	$("#failed_orders_num").text = unFinishedOrdersCount;
	$("#total_score_num").text = nScoreOrdersDelivered + nScoreSpeedBonus;

	for (var i = 1; i <= 3; i++)
		$("#round_end_star" + i).AddClass("UnReached");


	if (stars >= 1)
		$.Schedule(0.5, function(){ $("#round_end_star1").RemoveClass("UnReached"); });
	if (stars >= 2)
		$.Schedule(1.0, function(){ $("#round_end_star2").RemoveClass("UnReached"); });
	if (stars >= 3)
		$.Schedule(1.5, function(){ $("#round_end_star3").RemoveClass("UnReached"); });

	$("#round_end_summary").RemoveClass("Hidden");

	$.Schedule(10, function() {
		$("#round_end_summary").AddClass("Hidden");
	});

}

function CloseSummary() {
	$("#round_end_summary").AddClass("Hidden");
}

var n_CurrentHighscoreIndex = 0;

function OnHighScoreDataArrived() {
	var highscore_data = CustomNetTables.GetTableValue("highscore", "highscore");
	if (highscore_data != null){
		for (var i = 1; i <= 6; i++){
			var data = highscore_data[i+n_CurrentHighscoreIndex];
			if (data == undefined){
				$("#high_score_players_row_"+i).AddClass("NoPlayer");
			}else{
				$("#high_score_players_row_"+i).RemoveClass("NoPlayer");
				var players = JSON.parse(data.players);
				var score = data.score;
				for (var j = 0; j < Object.keys(players).length; j++) {
					$("#highscore_players_" + i.toString() + j.toString()).RemoveClass("EmptyPlayer");
					$("#highscore_players_" + i.toString() + j.toString()).steamid = players[i];
				}
				for (var k = Object.keys(players).length; k < 5; k++){
					$("#highscore_players_" + i.toString() + k.toString()).AddClass("EmptyPlayer");
				}
				$("#highscore_score_" + i).text = score;
			}
		}
		if (n_CurrentHighscoreIndex == 0) {
			$("#high_score_players_row_1").AddClass("Rank1");
			$("#high_score_players_row_2").AddClass("Rank2");
			$("#high_score_players_row_3").AddClass("Rank3");
		}else{
			$("#high_score_players_row_1").RemoveClass("Rank1");
			$("#high_score_players_row_2").RemoveClass("Rank2");
			$("#high_score_players_row_3").RemoveClass("Rank3");
		}
	}
}

(function() {
	GameEvents.Subscribe('show_round_end_summary', ShowRoundEndSummary);
	OnHighScoreDataArrived();
	CustomNetTables.SubscribeNetTableListener("highscore", OnHighScoreDataArrived);
})();
