#include "timed_execution/timed_execution.as"
#include "timed_execution/on_input_pressed_job.as"
#include "ronin/timed_execution/victory_job.as"
#include "ronin/timed_execution/defeat_job.as"

TimedExecution timer;
TimedExecution reset_timer;

bool skip_jobs = false;

void Init(string level_name){
    timer.Add(VictoryJob(function(){
        if (skip_jobs){
            return;
        }
        skip_jobs = true;
        level.SendMessage("displaytext \"You did it!\"");
        RegisterKeys();
    }));

    timer.Add(DefeatJob(function(_char){
        if (skip_jobs){
            return;
        }
        skip_jobs = true;
        level.SendMessage("displaytext \"You failed!\"");
        RegisterKeys();
    }));
}

void Update(int is_updated){
    timer.Update();
    reset_timer.Update();
}

bool HasFocus(){
    return false;
}

void DrawGUI(){}

void RegisterKeys(){
    reset_timer.Add(OnInputPressedJob(0, "space", function(){
        level.SendMessage("cleartext");
        level.SendMessage("reset");
        skip_jobs = false;
        reset_timer.DeleteAll();
        return false;
    }));
    
    reset_timer.Add(OnInputPressedJob(0, "esc", function(){
        level.SendMessage("go_to_main_menu");
        return false;
    }));
}
