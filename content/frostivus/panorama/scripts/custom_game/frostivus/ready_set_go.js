function StartReadySetGo(tab) {
  // The phase needs to be declared serverside because schedule is unreliable.
  
  if (!RSG_Panel) {
    var RSG_Panel = $.CreatePanel("Image",$.GetContextPanel().GetParent().GetParent().FindChildTraverse("FrostivusHUD"),"ReadySetGoPanel");
  }

  var imgname = 's2r://panorama/images/custom_game/ui/image_'.concat(tab.phase).concat('.png')
  imgname = 's2r://panorama/images/custom_game/ui/setting_keyboard.psd'
  RSG_Panel.SetImage(imgname);
}


(function() {
  // Use to test
  //StartReadySetGo("ready");
  GameEvents.Subscribe( "send_ready_set_go", StartReadySetGo);
})();
