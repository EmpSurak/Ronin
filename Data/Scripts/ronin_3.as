#include "timed_execution/timed_execution.as"
#include "timed_execution/after_init_job.as"
#include "timed_execution/delayed_job.as"
#include "timed_execution/on_input_pressed_job.as"
#include "ronin/timed_execution/victory_job.as"
#include "ronin/timed_execution/defeat_job.as"
#include "ronin/constants.as"

TimedExecution timer;
TimedExecution input_timer;

bool skip_jobs = false;
float current_time = 0.0f;
const vec3 _offset(0.0f, 0.3f, 0.0f);

void Init(string level_name){
    timer.Add(VictoryJob(function(){
        if(skip_jobs){
            return;
        }
        skip_jobs = true;

        EndLevel("You did it! Your time: " + GetTime(int(current_time)));
    }));

    timer.Add(DefeatJob(function(_char){
        int player_id = FindPlayerID();
        MovementObject@ player_char = ReadCharacterID(player_id);

        if(!_char.controlled){
            if(distance(player_char.position, _char.position) > 2.0f){
                DebugDrawLine(
                    player_char.rigged_object().skeleton().GetCenterOfMass() + _offset,
                    _char.rigged_object().skeleton().GetCenterOfMass() + _offset,
                    vec3(1.0f),
                    _delete_on_update
                );
            }
        }

        if(skip_jobs){
            return;
        }
        skip_jobs = true;

        if(player_char.GetIntVar("knocked_out") != _awake){
            EndLevel("You failed, you are dead!");
        }else if(_char.GetIntVar("goal") == _investigate){
            switch(_char.GetIntVar("sub_goal")){
                case _investigate_body:
                    EndLevel("You failed, body was found!");
                    break;
                default:
                    EndLevel("You failed, investigation started!");
                    break;
            }
        }else{
            EndLevel("You failed!");
        }
    }));
}

void Update(int is_updated){
    current_time += time_step;
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
            input_timer.DeleteAll();
            level.SendMessage("cleartext");
            level.SendMessage("reset");
            current_time = 0.0f;
            timer.Add(DelayedJob(1.0f, function(){
                skip_jobs = false;
            }));
        }));
        return false;
    }));

    input_timer.Add(OnInputPressedJob(0, "esc", function(){
        level.SendMessage("go_to_main_menu");
        return false;
    }));
}

void EndLevel(string message){
    string _controls = "Press SPACE to restart or ESCAPE to quit.";
    level.SendMessage("displaytext \"" + message + "\n" + _controls + "\"");
    timer.Add(DelayedJob(1.5f, function(){
        SetPaused(true);
        RegisterKeys();
    }));
}

int FindPlayerID(){
    int num = GetNumCharacters();
    for(int i = 0; i < num; ++i){
        MovementObject@ char = ReadCharacter(i);
        if(char.controlled){
            return char.GetID();
        }
    }
    return -1;
}

string GetTime(int seconds){
    int numSeconds = seconds % 60;
    int numMinutes = seconds / 60;
    if(numMinutes == 0){
        return numSeconds + " seconds";
    }else if(numMinutes == 1){
        return numMinutes + " minute and " + numSeconds + " seconds";
    }else{
        return numMinutes + " minutes and " + numSeconds + " seconds";
    }
}
