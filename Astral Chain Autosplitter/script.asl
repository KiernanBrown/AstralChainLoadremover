init
{
  refreshRate = 60;
  vars.prevPhase = TimerPhase.NotRunning;
  vars.fileDummy = false;
  vars.caseDummy = false;
  vars.finalSplit = false;
  vars.dummyFiles = new int[] { 10 };
  vars.endFiles = new int[] { 3, 9, 16, 24, 30, 41, 47, 50, 57, 65, 74 };
  features["end1"].pause();
  features["end2"].pause();
  vars.timerOffset = DateTime.Now;
}

update
{
  if (vars.prevPhase != timer.CurrentPhase && timer.CurrentPhase == TimerPhase.NotRunning) {
    // User manually reset. Reset variables.
    vars.fileDummy = false;
    vars.caseDummy = false;
    vars.finalSplit = false;
    features["end1"].pause();
    features["end2"].pause();
    features["start1"].resume();
    features["start2"].resume();
    features["start3"].resume();
    features["start4"].resume();
    timer.Run.Offset = TimeSpan.Zero;
  }
  
  if (vars.prevPhase == TimerPhase.NotRunning && timer.CurrentPhase == TimerPhase.Running) {
    // User manually started. Pause Start watchers.
    features["start1"].pause();
    features["start2"].pause();
    features["start3"].pause();
    features["start4"].pause();
  }

  if(!vars.fileDummy && features["file"].current > 90.0 && Array.IndexOf(vars.endFiles, timer.CurrentSplitIndex) != -1) {
    features["file"].pause(240000);
    vars.fileDummy = true;
  }
  
  if(!vars.finalSplit && timer.CurrentSplitIndex == (timer.Run.Count - 1)) {
    features["end1"].resume();
    features["end2"].resume();
    vars.finalSplit = true;
  }
  else if (vars.finalSplit && timer.CurrentSplitIndex != (timer.Run.Count - 1)) {
    features["end1"].pause();
    features["end2"].pause();
    vars.finalSplit = false;
  }
  
  vars.prevPhase = timer.CurrentPhase;
}

start
{
    if(features["start4"].current < 75.0 && features["start4"].old > 90.0) {
      vars.timerOffset = DateTime.Now;
    }
    
    if(features["start2"].min(500) > 60.0
    && features["start1"].max(1000) > 60.0
    && features["start1"].current < 30.0
    && features["start3"].max(1000) < 80.0) {
      features["start1"].pause();
      features["start2"].pause();
      features["start3"].pause();
      features["start4"].pause();
      timer.Run.Offset = DateTime.Now - vars.timerOffset;
      return true;
    }
    else return false;
}

reset
{
}

split
{
  if (vars.finalSplit
  && features["end1"].current < 75.0
  && features["end2"].current < 75.0
  && (features["end1"].max(1000) > 90.0
  || features["end2"].max(1000) > 90.0)) {
    vars.finalSplit = false;
    features["end1"].pause();
    features["end2"].pause();
    return true;
  }
  else if (features["case"].current > 93.0
  && features["blue"].max(300) > 93.0 
  && (features["case"].old < 93.0 
  || features["blue"].old < 93.0))
  {
    features["case"].pause(15000);
    features["blue"].pause(15000);
    if (Array.IndexOf(vars.dummyFiles, timer.CurrentSplitIndex) != -1) {
      vars.caseDummy = true;
      return false;
    } 
    else {
      return true;
    }
  }
  else if ((vars.fileDummy || vars.caseDummy) && features["black1"].current > 95.0)
  {
    vars.fileDummy = false;
    vars.caseDummy = false;
    return true;
  }
  else return false;
}