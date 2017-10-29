function RoundToTwo(num) {    
  return +(Math.round(num + "e+2")  + "e-2");
}

function ChannelingCheck()
{
  var wp = $.GetContextPanel().WorldPanel
  var data = $.GetContextPanel().Data
  
  if (wp) {
    $("#Progress").style.width = RoundToTwo(data.progress) + "%";

    $("#Progress").SetHasClass("Oscillate", data.progress == 100);

    // if (!$.GetContextPanel().Initiated && data.progress) {
    //   $("#Progress").style.transitionDuration = data.duration + "s;";
    //   $("#Progress").style.width = data.progress + "%";

    //    $.GetContextPanel().Initiated = true;
    // }
  }

  $.Schedule(1/30, ChannelingCheck);
}

(function()
{ 
  ChannelingCheck();

})();