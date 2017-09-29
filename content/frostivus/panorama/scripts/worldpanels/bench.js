function BenchCheck()
{
  var wp = $.GetContextPanel().WorldPanel
  var data = $.GetContextPanel().Data

  if (wp) {
    
  }

  $.Schedule(1/30, BenchCheck);
}

(function()
{ 
  BenchCheck();

})();