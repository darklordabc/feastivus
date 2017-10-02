function BenchCheck()
{
  var wp = $.GetContextPanel().WorldPanel
  var data = $.GetContextPanel().Data

  if (wp && data) {
    for (var i = 1; i < 4; i++) {
      if (data[i]) {
        $("#Slot"+i).itemname = data[i];
        $("#Slot"+i).SetHasClass("Hide", false);
      } else {
        $("#Slot"+i).SetHasClass("Hide", true);
      }
    }
  }

  $.Schedule(1/30, BenchCheck);
}

(function()
{ 
  BenchCheck();

})();