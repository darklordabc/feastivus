function NewRound(args) {
	$.Each(args.recipe, function(v, k) {
		var item = $.CreatePanel('Panel', $("#recipe"), v);
    	item.BLoadLayoutSnippet("Item");
    	item.hittest = false;
    	item.FindChildTraverse("itemIcon").itemname = v;
	});
}

(function () {
	GameEvents.Subscribe("frostivus_new_round", NewRound)
})();