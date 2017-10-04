function ChannelingCheck()
{
  var wp = $.GetContextPanel().WorldPanel
  var data = $.GetContextPanel().Data
  
  if (wp) {
    if (!$.GetContextPanel().Initiated && data.duration) {
      $("#Progress").style.transitionDuration = data.duration + "s;";
      $("#Progress").style.width = "100%";

      $.GetContextPanel().Initiated = true;
    }
  }

  $.Schedule(1/30, ChannelingCheck);
}

(function()
{ 
  ChannelingCheck();

})();