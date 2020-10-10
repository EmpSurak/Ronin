#include "timed_execution/basic_job_interface.as"

funcdef void DEBUG_LINE_CALLBACK(MovementObject@, MovementObject@);

class DebugLineJob : BasicJobInterface {
    protected int player_id;
    protected int enemy_id;
    protected DEBUG_LINE_CALLBACK @callback;

    DebugLineJob(){}

    DebugLineJob(int _player_id, int _enemy_id, DEBUG_LINE_CALLBACK @_callback){
        player_id = _player_id;
        enemy_id = _enemy_id;
        @callback = @_callback;
    }

    void ExecuteExpired(){
        if(!MovementObjectExists(player_id) || !MovementObjectExists(enemy_id)){
            return;
        }
        MovementObject @player = ReadCharacterID(player_id);
        MovementObject @enemy = ReadCharacterID(enemy_id);

        callback(player, enemy);
    }

    bool IsExpired(){
        return true;
    }

    bool IsRepeating(){
        return true;
    }
}
