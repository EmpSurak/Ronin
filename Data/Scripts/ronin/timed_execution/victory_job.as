#include "timed_execution/basic_job_interface.as"

funcdef void ON_VICTORY_CALLBACK();

class VictoryJob : BasicJobInterface {
    protected ON_VICTORY_CALLBACK @callback;

    VictoryJob(){}

    VictoryJob(ON_VICTORY_CALLBACK @_callback){
        @callback = @_callback;
    }

    void ExecuteExpired(){
        callback();
    }

    bool IsExpired(){
        return !NotAllEnemiesAreDead();
    }

    bool IsRepeating(){
        return true;
    }
    
    bool NotAllEnemiesAreDead(){
        int num = GetNumCharacters();
        for(int i = 0; i < num; ++i){
            MovementObject@ char = ReadCharacter(i);
            
            if (char.controlled){
                continue;
            }
            
            if(char.GetIntVar("knocked_out") == _awake){
                return true;
            }
        }
        
        return false;
    }
}