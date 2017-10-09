var m_Recipes = null;
var m_OrderPanels = {};

function OnOrderChanged() {
	var orders = CustomNetTables.GetTableValue("orders", "orders");

	var parent = $("#orders");

	for (var k in orders) {
		var order = orders[k];
		var orderId = order.pszID
		var itemName = order.pszItemName
		var timeRemaining = order.nTimeRemaining

		var orderPanel = parent.FindChildTraverse(orderId);
		
		if (orderPanel == undefined) {
			// create new panel
			orderPanel = $.CreatePanel("Panel", parent, orderId);
			orderPanel.BLoadLayoutSnippet("Order");

			orderPanel.FindChildTraverse("ProductImage").itemname = itemName;

			if (m_Recipes == null) {
				OnRecipesChanged();
			}

			var assemblies = m_Recipes[itemName];

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
		orderPanel.FindChildTraverse('time_remaining').style.width = 100 * timeRemaining / 60 + "%";

		if (timeRemaining < 10){
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
			m_OrderPanels[k].DeleteAsync(0);
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

(function(){
	OnRecipesChanged();
	CustomNetTables.SubscribeNetTableListener("orders", OnOrderChanged);
	CustomNetTables.SubscribeNetTableListener("recipes", OnRecipesChanged);
})();