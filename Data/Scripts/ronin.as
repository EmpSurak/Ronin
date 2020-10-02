#include "timed_execution/timed_execution.as"
#include "timed_execution/on_input_pressed_job.as"
#include "ronin/timed_execution/victory_job.as"
#include "ronin/timed_execution/defeat_job.as"

TimedExecution timer;

void Init(string level_name){
    timer.Add(VictoryJob(function(){
        level.SendMessage("displaytext \"You did it!\"");

        timer.Add(OnInputPressedJob(0, "space", function(){
            level.SendMessage("cleartext");
            level.SendMessage("reset");
            return false;
        }));
        
        timer.Add(OnInputPressedJob(0, "esc", function(){
            level.SendMessage("go_to_main_menu");
            return false;
        }));
    }));

    timer.Add(DefeatJob(function(){
        level.SendMessage("displaytext \"You failed!\"");

        timer.Add(OnInputPressedJob(0, "space", function(){
            level.SendMessage("cleartext");
            level.SendMessage("reset");
            return false;
        }));
        
        timer.Add(OnInputPressedJob(0, "esc", function(){
            level.SendMessage("go_to_main_menu");
            return false;
        }));
    }));
}

void Update(){
    timer.Update();
}

bool HasFocus(){
    return false;
}

void DrawGUI(){}
