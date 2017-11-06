var m_Recipes = null;
var m_OrderPanels = {};
var m_TutorialOrders = {};

var m_Subscription = null;

function OnOrderChanged(table_name, key, data) {
	if (key == "tutorial") return;
	var orders = data;//CustomNetTables.GetTableValue("orders", "orders");
	var tutorial = CustomNetTables.GetTableValue("orders", "tutorial");

	var parent = $("#orders");

	for (var k in orders) {
		var order = orders[k];
		var orderId = order.pszID
		var itemName = order.pszItemName
		var timeRemaining = order.nTimeRemaining
		var timeLimit = order.nTimeLimit
		var finishType = order.pszFinishType;

		if (tutorial) {
			timeRemaining = timeLimit;

			// check if order is complete
			if (tutorial[Players.GetLocalPlayer()] && tutorial[Players.GetLocalPlayer()][orderId]) {
				finishType = "Finished";
			}
		}

		var orderPanel = parent.FindChildTraverse(orderId);
		
		if (orderPanel == undefined) {
			// create new panel
			orderPanel = $.CreatePanel("Panel", parent, orderId);
			orderPanel.BLoadLayoutSnippet("Order");
			orderPanel.SetHasClass("OrderAppear", false);

			orderPanel.FindChildTraverse("ProductImage").itemname = itemName;

			if (m_Recipes == null) {
				OnRecipesChanged();
			}

			var assemblies = m_Recipes[itemName];

			$.Msg(assemblies);

			if (assemblies != undefined) {
				for (var i = 0; i < Object.keys(assemblies).length; ++i){
					orderPanel.FindChildTraverse("Assembly_Image_" + i).itemname = assemblies[i+1];
				}

				for (var i = Object.keys(assemblies).length; i < 4; ++i) {
					orderPanel.FindChildTraverse("Assembly_Panel_" + i).AddClass("Hidden");
				}
			}

			m_OrderPanels[orderId] = orderPanel;
		}

		// update time left
		orderPanel.FindChildTraverse('time_remaining').style.transitionDuration = "1s";
		orderPanel.FindChildTraverse('time_remaining').style.width = 100 * timeRemaining / timeLimit + "%";

		if (finishType == "Finished") {
			orderPanel.SetHasClass("TimeRunningOut", false);
			orderPanel.AddClass("Finished");
		}else if (finishType == "Expired") {
			orderPanel.SetHasClass("TimeRunningOut", false);
			orderPanel.AddClass("Expired");
		}else if (timeRemaining < 10){
			orderPanel.SetHasClass("TimeRunningOut", true);
		}
	}

	for (var k in m_OrderPanels){
		var found = false;
		for ( var kk in orders) {
			if (orders[kk].pszID == k) {
				found = true;
			}
		}
		if (!found) {
			m_OrderPanels[k].DeleteAsync(0.5);
			m_OrderPanels[k].SetHasClass("OrderAppear", true);

			delete m_OrderPanels[k];
		}

	}

}

function OnRecipesChanged() {

	var recipes = CustomNetTables.GetAllTableValues("recipes");
	m_Recipes = {};

	for (var k in recipes){
		var recipe = recipes[k];
		m_Recipes[recipe.key] = recipe.value
	}
}

function OnTutorialDone(keys) {
	$.Msg(keys);
	m_TutorialOrders[keys.order] = keys.lowestTime;
	// 
	// orders[keys.order].pszFinishType = "Finished";
	// Unsubscribe()
	// OnOrderChanged("orders", "orders", orders);
	// $.Schedule(1.0, function () {
	// 	OnOrderChanged("orders", "orders", {});
	// 	// Subscribe();
	// });
}

function Subscribe() {
	m_Subscription = CustomNetTables.SubscribeNetTableListener("orders", OnOrderChanged);
}

function Unsubscribe() {
	CustomNetTables.UnsubscribeNetTableListener(m_Subscription)
}

(function(){
	OnRecipesChanged();
	CustomNetTables.SubscribeNetTableListener("recipes", OnRecipesChanged);

	Subscribe();
	
	GameEvents.Subscribe("frostivus_tutorial_order", OnTutorialDone);
	GameEvents.Subscribe("frostivus_resubscribe", Subscribe);
})();