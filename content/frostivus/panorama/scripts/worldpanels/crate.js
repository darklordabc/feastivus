(function()
{ 
  GameEvents.Subscribe("frostivus_crate_item", (function (args) {
	if(args.id == $.GetContextPanel().GetOwnerEntityID())
	{
		$("#Item").itemname = args.item;
	}
  }));
})();