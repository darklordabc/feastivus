function AddMessage() {

	var duration = 5;
	var panel = $.CreatePanel("Panel", $("#message_center_panel"), "");
	panel.BLoadLayoutSnippet("Message");
	panel.AddClass("Negative");
	panel.DeleteAsync(duration)
}

(function() {
	$.Schedule(2, function() {
		AddMessage();
	})
	$.Schedule(3, function() {
		AddMessage();
	})
	$.Schedule(5, function() {
		AddMessage();
	})
	$.Schedule(8, function() {
		AddMessage();
	})
})();