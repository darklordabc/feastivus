(function()
{ 
  GameEvents.Subscribe("frostivus_crate_item", (function (args) {
  	$.Msg("ssdsdfsdf");
	if(args.id == $.GetContextPanel().GetOwnerEntityID())
	{
		$("#Item").itemname = args.item;
	}
  }));
})();