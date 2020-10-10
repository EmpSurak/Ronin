#include "timed_execution/timed_execution.as"
#include "timed_execution/after_init_job.as"
#include "timed_execution/delayed_job.as"
#include "timed_execution/on_input_pressed_job.as"
#include "timed_execution/level_event_job.as"
#include "ronin/timed_execution/victory_job.as"
#include "ronin/timed_execution/defeat_job.as"
#include "ronin/timed_execution/debug_line_job.as"
#include "ronin/constants.as"
#include "ronin/end_screen.as"

TimedExecution timer;
EndScreen end_screen;

float current_time = 0.0f;
const vec3 _line_offset(0.0f, 0.3f, 0.0f);

void Init(string level_name){
    timer.Add(VictoryJob(function(){
        EndLevel("You did it, boss!", 5.0f);
    }));

    timer.Add(DefeatJob(function(_enemy_char){
        int player_id = FindPlayerID();
        MovementObject@ player_char = ReadCharacterID(player_id);

        timer.Add(DebugLineJob(player_id, _enemy_char.GetID(), function(_player_char, _enemy_char){
            if(distance(_player_char.position, _enemy_char.position) < 2.0f){
                return;
            }

            DebugDrawLine(
                _player_char.rigged_object().skeleton().GetCenterOfMass() + _line_offset,
                _enemy_char.rigged_object().skeleton().GetCenterOfMass() + _line_offset,
                vec3(1.0f),
                _delete_on_update
            );
        }));

        if(player_char.GetIntVar("knocked_out") != _awake){
            EndLevel("You failed, you are dead!");
        }else if(_enemy_char.GetIntVar("goal") == _investigate){
            switch(_enemy_char.GetIntVar("sub_goal")){
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

    timer.Add(LevelEventJob("reset", function(_params){
        timer.DeleteAll();
        end_screen.Reset();
        current_time = 0.0f;

        timer.Add(DelayedJob(1.0f, function(){
            Init("");
        }));
        return false;
    }));
}

void Update(int is_paused){
    current_time += time_step;
    timer.Update();
    end_screen.Update();
}

bool HasFocus(){
    return false;
}

void DrawGUI(){
    end_screen.Render();
}

void ReceiveMessage(string msg){
    timer.AddLevelEvent(msg);
}

void RegisterKeys(){
    timer.Add(OnInputPressedJob(0, "space", function(){
        SetPaused(false);
        timer.Add(AfterInitJob(function(){
            level.SendMessage("reset");
        }));
        return false;
    }));

    timer.Add(OnInputPressedJob(0, "esc", function(){
        level.SendMessage("go_to_main_menu");
        return false;
    }));
}

void EndLevel(string message, float delay = 1.5f){
    end_screen.ShowMessage(message, current_time);

    timer.Add(DelayedJob(delay, function(){
        end_screen.ShowControls();    
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
