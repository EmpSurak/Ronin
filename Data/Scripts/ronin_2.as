#include "timed_execution/timed_execution.as"
#include "timed_execution/after_init_job.as"
#include "timed_execution/delayed_job.as"
#include "timed_execution/on_input_pressed_job.as"
#include "ronin/timed_execution/victory_job.as"
#include "ronin/timed_execution/defeat_job.as"

TimedExecution timer;
TimedExecution input_timer;

bool skip_jobs = false;

void Init(string level_name){
    timer.Add(VictoryJob(function(){
        if(skip_jobs){
            return;
        }
        skip_jobs = true;

        EndLevel("You did it! Press SPACE to restart.");
    }));

    timer.Add(DefeatJob(function(_char){
        if(skip_jobs){
            return;
        }
        skip_jobs = true;

        EndLevel("You failed! Press SPACE to restart.");
    }));
}

void Update(int is_updated){
    timer.Update();
    input_timer.Update();
}

bool HasFocus(){
    return false;
}

void DrawGUI(){}

void RegisterKeys(){
    input_timer.Add(OnInputPressedJob(0, "space", function(){
        SetPaused(false);
        timer.Add(AfterInitJob(function(){
            level.SendMessage("cleartext");
            level.SendMessage("reset");
            skip_jobs = false;
            input_timer.DeleteAll();
        }));
        return false;
    }));

    input_timer.Add(OnInputPressedJob(0, "esc", function(){
        level.SendMessage("go_to_main_menu");
        return false;
    }));
}

void EndLevel(string message){
    level.SendMessage("displaytext \"" + message + "\"");
    timer.Add(DelayedJob(1.5f, function(){
        SetPaused(true);
        RegisterKeys();
    }));
}
