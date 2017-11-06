function RoundToTwo(num) {    
  return +(Math.round(num + "e+2")  + "e-2");
}

function ChannelingCheck()
{
  var wp = $.GetContextPanel().WorldPanel
  var data = $.GetContextPanel().Data
  
  if (wp) {
    if (data.progress) {
      $("#Progress").style.width = RoundToTwo(data.progress) + "%";
    }
    
    if (data.overtime && data.max_overtime) {
      $("#Progress").style.animationDuration = Math.max(RoundToTwo((data.max_overtime - Math.min(data.overtime, data.max_overtime - 0.1)) / 5), 0.2) + "s;";
    }

    $("#Progress").SetHasClass("Oscillate", data.progress == 100);
    $("#Frame").SetHasClass("Hide", data.hidden);

    if (data.cooking_done) {
      // $("#Frame").style.opacity = "0.0;";
    }

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