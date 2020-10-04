#include "timed_execution/timed_execution.as"
#include "timed_execution/after_init_job.as"
#include "timed_execution/delayed_job.as"
#include "timed_execution/on_input_pressed_job.as"
#include "ronin/timed_execution/victory_job.as"
#include "ronin/timed_execution/defeat_job.as"
#include "ronin_enemycontrol.as"

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
        int player_id = FindPlayerID();
        MovementObject@ player_char = ReadCharacterID(player_id);

        if(!_char.controlled){
            if(distance(player_char.position, _char.position) > 2.0f){
                vec3 _offset(0.0f, 0.9f, 0.0f);
                DebugDrawLine(player_char.position + _offset, _char.position + _offset, vec3(1.0f), _delete_on_update);
            }
        }

        if(skip_jobs){
            return;
        }
        skip_jobs = true;

        if(player_char.GetIntVar("knocked_out") != _awake){
            EndLevel("You failed, you are dead! Press SPACE to restart.");
        }else if(_char.GetIntVar("goal") == _investigate){
            switch(_char.GetIntVar("sub_goal")){
                case _investigate_body:
                    EndLevel("You failed, body was found! Press SPACE to restart.");
                    break;
                default:
                    EndLevel("You failed, investigation started! Press SPACE to restart.");
                    break;
            }
        }else{
            EndLevel("You failed! Press SPACE to restart.");
        }
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
