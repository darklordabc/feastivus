function RoundToTwo(num) {    
  return +(Math.round(num + "e+2")  + "e-2");
}

function BenchCheck()
{
  var wp = $.GetContextPanel().WorldPanel
  var data = $.GetContextPanel().Data

  if ($.GetContextPanel().InitiatedLayout && !Entities.IsValidEntity(wp.entity)) {
    $.GetContextPanel().DeleteWorldPanel();
    return;
  }

  if (wp && data) {
    var layout = data.layout;
    var hidden = data.hidden;
    var fake = data.fake;

    if (hidden) {
      $.GetContextPanel().SetHasClass("Hide", true);
    } else {
      $.GetContextPanel().SetHasClass("Hide", false);
      
      if (!$.GetContextPanel().InitiatedLayout || layout != $.GetContextPanel().Layout || fake != $.GetContextPanel().Fake) {
        $.GetContextPanel().Layout = layout;
        $.GetContextPanel().Fake = fake;

        if (fake != undefined) {
          layout = 1;
        }

        for (var i = 1; i < 4; i++) {
          $("#Slot"+i).SetHasClass("Collapse", false);
        }

        for (var i = layout+1; i <= 4; i++) {
          $("#Slot"+i).SetHasClass("Collapse", true)
        }

        $("#Slot1").SetHasClass("Single", layout == 1);
        $("#Row1").SetHasClass("Centered", layout == 1);

        $.GetContextPanel().InitiatedLayout = true;
      } else {
        if (fake) {
          $("#Slot"+1).Children()[0].itemname = fake;
          $("#Slot"+1).Children()[0].SetHasClass("Hide", false);
        } else {
          for (var i = 0; i < layout; i++) {
            var id = i+1;
            if (data.items[id]) {
              $("#Slot"+id).Children()[0].itemname = data.items[id];
              $("#Slot"+id).Children()[0].SetHasClass("Hide", false);
            } else if ($("#Slot"+id)) {
              $("#Slot"+id).Children()[0].SetHasClass("Hide", true);
            }
          }
        }
      }

      function clearProgress() {
        $("#Outline1").SetHasClass("OutlineYellow", false);

        $("#Outline1").style.clip = "radial(50% 50%, 0deg, 0deg);";
        $("#Outline1").style.transitionDuration = 0 + "s;";
        $("#Outline1").style.clip = "radial(50% 50%, 0deg, 0deg);";

        data.duration = undefined;

        try {
          $.CancelScheduled($.GetContextPanel().Schedule);
        } catch (e) {

        }

        $.GetContextPanel().InitiatedChanneling = false;
      }

      if (!$.GetContextPanel().InitiatedChanneling && data.duration) {
        $("#Outline1").SetHasClass("Hide", false);
        $("#Outline1").SetHasClass("OutlineYellow", true);

        if (!data.paused) {
          $("#Outline1").style.clip = "radial(50% 50%, 0deg, 0deg);";
        }

        $("#Outline1").style.transitionDuration = RoundToTwo(data.duration) + "s;";
        $("#Outline1").style.clip = "radial(50% 50%, 0deg, 360deg);";

        $.GetContextPanel().Schedule = $.Schedule(RoundToTwo(data.duration), (function () {
          clearProgress()

          $("#Outline1").style.clip = "radial(50% 50%, 0deg, 360deg);";
        }));

        $.GetContextPanel().InitiatedChanneling = true;
      } else if ($.GetContextPanel().InitiatedChanneling && data.paused && !data.duration) { // Interrupt and pause
        clearProgress()

        $("#Outline1").SetHasClass("OutlineYellow", true);
        $("#Outline1").style.transitionDuration = 0 + "s;";
        $("#Outline1").style.clip = "radial(50% 50%, 0deg, " + Math.round(data.paused * 360) + "deg);";
      }
    }
  }

  $.Schedule(1/30, BenchCheck);
}

(function()
{ 
  BenchCheck();

})();