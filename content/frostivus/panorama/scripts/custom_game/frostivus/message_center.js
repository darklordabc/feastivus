var m_AllMessagePanels = { };

function OnShowMessage(args) {
	var id = args.id;
	var item = args.item;
	var icon = args.icon;
	var text = args.text;
	var duration = args.duration

	$.Msg("OnDemandShowMessage", args)

	var panel = $.CreatePanel("Panel", $("#message_center_panel"), "");
	panel.BLoadLayoutSnippet("Message");

	if (item !== undefined) {
		panel.FindChildTraverse("images_panel").RemoveClass("NoImage");
		panel.FindChildTraverse("item_image").RemoveClass("NoImage");
		panel.FindChildTraverse("item_image").itemname = item;
	}
	
	if (icon !== undefined) {
		panel.FindChildTraverse("images_panel").RemoveClass("NoImage");
		panel.FindChildTraverse("normal_image").RemoveClass("NoImage");
		panel.FindChildTraverse("normal_image").SetImage("file://{resources}/images/custom_game/msgs/" + icon);
	}

	panel.FindChildTraverse("message_text").text = $.Localize(text);

	if (duration != undefined) {
		$.Schedule(duration - 0.5, function(){panel.AddClass("Fadeout"); });
		panel.DeleteAsync(duration)
	}else{
		// store the id for delete
		m_AllMessagePanels[id] = panel;
	}

	// fail safe delele message in 30 seconds
	$.Schedule(30, function(){
		if (m_AllMessagePanels[id] != undefined ) {
			m_AllMessagePanels[id].AddClass("Fadeout");
			m_AllMessagePanels[id].DeleteAsync(0.5);
		} 
	});
}

function OnRemoveMessage(args) {
	var id = args.id
	if (m_AllMessagePanels[id] != null){
		m_AllMessagePanels[id].AddClass("Fadeout");
		m_AllMessagePanels[id].DeleteAsync(0.5);
		delete m_AllMessagePanels[id];
	}
}

(function() {
	GameEvents.Subscribe('frostivus_show_message', OnShowMessage);
	GameEvents.Subscribe('frostivus_remove_message', OnRemoveMessage);
})();