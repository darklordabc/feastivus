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

	var summary_panel = $("#round_end_summary");

	$("#finished_orders_count").text = finishedOrdersCount + "/" + allOrders;

	// show stars
	// @todo, find decent sound for stars and round end summary?
	var perfect = false;
	if (stars >= 4){
		stars = 3;
		perfect = true;
	}

	for (var i = 1; i <= 3; i++)
		$("#round_end_star" + i).AddClass("UnReached");

	if (stars >= 1)
		$.Schedule(0.5, function(){ $("#round_end_star1").RemoveClass("UnReached"); });
	if (stars >= 2)
		$.Schedule(1.0, function(){ $("#round_end_star2").RemoveClass("UnReached"); });
	if (stars >= 3)
		$.Schedule(1.5, function(){ $("#round_end_star3").RemoveClass("UnReached"); });

	if (perfect) {
		$.Schedule(2, function() {
			$("#perfect_panel").RemoveClass("Hidden");
			// @todo perfect sound!
		});	
	}

	$.Schedule(10, function() {
		CloseSummary();
	});

	$("#round_end_summary").RemoveClass("Hidden");
}

function CloseSummary() {
	$("#round_end_summary").AddClass("Hidden");
}

(function() {
	GameEvents.Subscribe('show_round_end_summary', ShowRoundEndSummary);
	ShowRoundEndSummary({
		Stars: 4,
		FinishedOrdersCount: 16,
		UnFinishedOrdersCount: 0,
	})
	
})();