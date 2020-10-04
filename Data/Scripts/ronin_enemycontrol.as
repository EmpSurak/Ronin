enum AIGoal {
    _patrol,
    _attack,
    _investigate,
    _get_help,
    _escort,
    _get_weapon,
    _navigate,
    _struggle,
    _hold_still,
    _flee
};

enum AISubGoal {
    _unknown = -1,
    _provoke_attack,
    _avoid_jump_kick,
    _knock_off_ledge,
    _wait_and_attack,
    _rush_and_attack,
    _defend,
    _surround_target,
    _escape_surround,
    _investigate_slow,
    _investigate_urgent,
    _investigate_body,
    _investigate_around,
    _investigate_attack
};