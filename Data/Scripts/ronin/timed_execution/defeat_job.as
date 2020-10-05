#include "timed_execution/basic_job_interface.as"
#include "ronin/constants.as"

funcdef void ON_DEFEAT_CALLBACK(MovementObject@);

class DefeatJob : BasicJobInterface {
    protected int last_char;
    protected ON_DEFEAT_CALLBACK @callback;

    DefeatJob(){}

    DefeatJob(ON_DEFEAT_CALLBACK @_callback){
        @callback = @_callback;
    }

    void ExecuteExpired(){
        if(!MovementObjectExists(last_char)){
            return;
        }
        MovementObject @char = ReadCharacterID(last_char);

        callback(char);
    }

    bool IsExpired(){
        int num = GetNumCharacters();
        for(int i = 0; i < num; ++i){
            MovementObject@ char = ReadCharacter(i);
            last_char = char.GetID();

            if(char.controlled){
                if(char.GetIntVar("knocked_out") != _awake){
                    return true;
                }
                continue;
            }else if(char.GetIntVar("knocked_out") != _awake || char.GetIntVar("tethered") == _TETHERED_REARCHOKED){
                continue;
            }

            if(char.GetIntVar("goal") != _patrol && char.GetIntVar("goal") != _struggle && char.GetIntVar("goal") != _get_weapon){
                if(char.GetIntVar("goal") == _investigate){
                    if(char.GetIntVar("sub_goal") != _investigate_slow && char.GetIntVar("sub_goal") != _investigate_around){
                        return true;
                    }
                }else{
                    return true;
                }
            }
        }

        return false;
    }

    bool IsRepeating(){
        return true;
    }
}
