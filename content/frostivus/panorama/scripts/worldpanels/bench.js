function BenchCheck()
{
  var wp = $.GetContextPanel().WorldPanel
  var data = $.GetContextPanel().Data

  if (wp && data) {
    var layout = data.layout;

    if (!$.GetContextPanel().InitiatedLayout || layout != $.GetContextPanel().Layout) {
      $.GetContextPanel().Layout = layout;

      for (var i = layout+1; i <= 4; i++) {
        $("#Slot"+i).SetHasClass("Collapse", true)
      }

      $("#Slot1").SetHasClass("Single", layout == 1);
      $("#Row1").SetHasClass("Centered", layout == 1);

      $.GetContextPanel().InitiatedLayout = true;
    } else {
      for (var i = 0; i < layout; i++) {
        var id = i+1;
        if (data.items[id]) {
          $("#Slot"+id).Children()[0].itemname = data.items[id];
          $("#Slot"+id).Children()[0].SetHasClass("Hide", false);
        } else {
          $("#Slot"+id).Children()[0].SetHasClass("Hide", true);
        }
      }
    }

    if (!$.GetContextPanel().InitiatedChanneling && data.duration) {
      $("#Frame").SetHasClass("Hide", false);

      $("#Progress").style.transitionDuration = data.duration + "s;";
      $("#Progress").style.width = "100%";

      $.Schedule(data.duration, (function () {
        $("#Frame").SetHasClass("Hide", true);

        $("#Progress").style.transitionDuration = 0 + "s;";
        $("#Progress").style.width = "0%";

        data.duration = undefined;

        $.GetContextPanel().InitiatedChanneling = false;
      }));

      $.GetContextPanel().InitiatedChanneling = true;
    }
  }

  $.Schedule(1/30, BenchCheck);
}

(function()
{ 
  BenchCheck();

})();