state("RaccoonCity")
{
    byte CLL: 0xA5391C;
    byte CS: 0x9D038, 0x4;
    byte inCutscene: 0xC1C920; // 0 = In Cutscene, 1 = Not In Cutscene
    byte isPaused: 0xBF9810; // 0 = Paused, 1 = Unpaused
    byte Mission: 0xAB1750;
    byte Results: 0x18EBF8, 0x16C;
    float Time: 0xBEEF7C, 0x14, 0x0, 0x260;
    int Menu: 0x09BCB8, 0x20;
}


startup
{
    settings.Add("TM", true, "Timing Method");
    settings.Add("PlayerCount", true, "Solo || Co-op");
    settings.Add("Blank", false, "=====================");
    settings.Add("MC", true, "Main Campaign");
    settings.Add("EC", false, "DLC Campaign");
    settings.Add("IL", false, "Individual Levels");

    settings.CurrentDefaultParent = "TM";
    settings.Add("IGT", true, "Enable IGT Timing");
    settings.Add("sIGT", false, "Enable sIGT Timing");

    settings.CurrentDefaultParent = "IGT";
    settings.Add("TimeFloor", false, "Enable Time Flooring");

    settings.CurrentDefaultParent = "PlayerCount";
    settings.Add("Solo", true, "Solo");
    settings.Add("Co-op", false, "Co-op");

    settings.CurrentDefaultParent = null;

    vars.TotalTime = 0;
    vars.CSCheck = false;
    vars.MissionCheck = false;
}


start
{
    if(current.Time != old.Time){
        if(settings["MC"] && current.Mission == 1){
            vars.TotalTime = 0;
            return true;
        }
        
        else if(settings["EC"] && current.Mission == 11){
            vars.TotalTime = 0;
            return true;
        }
        
        else if(settings["IL"]){
            vars.TotalTime = 0;
            return true;
        }
    }

}


split
{
    vars.CSCheck = (current.CS != old.CS && current.CS == 2);
    vars.MissionCheck = (current.Mission > old.Mission);

    if(settings["MC"]){
        if(current.Mission == 7 && current.Results == 1 && current.Time == old.Time){
            return true;
        }

        else if(vars.CSCheck == true){
            return true;
        }
    }


    if(settings["EC"]){
        if(current.Mission == 17 && current.Results == 1 && current.Time == old.Time){
            return true;
        }

        else if(vars.MissionCheck == true){
            return true;
        }
    }


    if(settings["IL"]){
        if(current.Results == 1 && current.Time == old.Time){
            return true;
        }
    }
}


isLoading
{
    if(settings["IGT"] == true){
        return true;
    }
    

    if(settings["sIGT"] == true){
        if(settings["Solo"] == true){
            if(current.CLL == 72 || current.CS == 2 || current.inCutscene == 0 || current.isPaused == 0 || current.Results == 1){
                return true;
            }

            else if(current.Time > old.Time){
                return false;
            }
        }

        if(settings["Co-op"] == true){
            if(current.CLL == 72 || current.CS == 2 || current.inCutscene == 0 || current.Results == 1){
                return true;
            }

            else if(current.Time > old.Time){
                return false;
            }

            if(settings["EC"]){
                if(current.Menu == 1){
                    return true;
                }
            }
        }
    }
}


gameTime
{
    if(settings["IGT"]){
        if(current.Time != old.Time && current.Time == 0){
            vars.TotalTime += old.Time;
        }

        if(settings["TimeFloor"] == true){
            return TimeSpan.FromSeconds(System.Math.Floor(vars.TotalTime + old.Time));
        }
    
        else if(settings["TimeFloor"] == false){
            return TimeSpan.FromSeconds(vars.TotalTime + old.Time);
        }
    }
}


reset
{
    if(settings["EC"] && settings["Co-op"]){
        return false;
    }


    else if(current.Menu == 1){
        vars.TotalTime = 0;
        return true;
    }
}