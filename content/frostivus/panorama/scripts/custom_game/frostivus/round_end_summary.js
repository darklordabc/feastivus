// CustomGameEventManager:Send_ServerToAllClients('show_round_end_summary',{
// 		Stars = stars,
// 		FinishedOrdersCount = table.count(self.vFinishedOrders),
// 		UnFinishedOrdersCount = table.count(self.vPendingOrders),
// 	})

function ShowRoundEndSummary(args) {
	$.Msg("round end summary");
	$.Msg(args);
	var stars = args.Stars;
	var finishedOrdersCount = args.FinishedOrdersCount;
	var unFinishedOrdersCount = args.UnFinishedOrdersCount;
	var allOrders = finishedOrdersCount + unFinishedOrdersCount;

	var summary_panel = $("#round_end_summary");

	$("#finished_orders_count").text = finishedOrdersCount + "/" + allOrders;

	// show stars
	// @todo, find decent sound for stars and round end summary?
	var perfect = false;
	if (stars >= 4){
		stars = 3;
		perfect = true;
	}

	for (var i = 1; i <= stars; ++i){
		$.Schedule(i / 2, function(){
			$("#round_end_star" + i).RemoveClass("UnReached");
		});
	}

	if (perfect) {
		$.Schedule(2, function() {
			$("#perfect_panel").RemoveClass("Hidden");
		});	
	}

	$.Schedule(10, function() {
		CloseSummary();
	});
}

function CloseSummary() {
	$("#round_end_summary").AddClass("Hidden");
}

(function() {
	GameEvents.Subscribe('show_round_end_summary', ShowRoundEndSummary);
})();