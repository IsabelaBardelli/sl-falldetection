// Configurações
float start_time = 0.0;
float time_in_air = 0.0;
float lock_time = 0.0;
vector last_position;

float fall_threshold = 1.0; // Min time to detect impact
float lock_thereshold = 60.0; // Anim duration
float timer_thereshold = 0.1; // Timer

// Impacto anim name
string impact_animation = "Falling_hard"; // Substitua pelo nome da animação desejada
integer impact_active = FALSE;

float positive_mod_float(float a, float b)
{
    float result = a - b;
    if (result >= 0) return result;
    else return result * -1;
}

default
{
    state_entry()
    {
        last_position = llGetPos();
        llSetTimerEvent(timer_thereshold);
       
    }

    timer()
    {
        if (impact_active)
        {
            lock_time -= timer_thereshold;

            if (lock_time <= 0.0)
            {
                llReleaseControls();
                llStopAnimation(impact_animation);
                impact_active = FALSE;
                llSetTimerEvent(0.1);
            }
            return;
        }

        vector current_position = llGetPos();

        if (positive_mod_float(current_position.z, last_position.z) > 0.8 && start_time == 0.0)
        {
            start_time = llGetTime();
        } else if (current_position.z >= last_position.z && start_time != 0.0)
        {
            time_in_air = llGetTime() - start_time;
            if (time_in_air > fall_threshold)
            {
                llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS);
            }
            
            start_time = 0.0;
        }

        last_position = current_position; 
    }

    run_time_permissions(integer permissions)
    {
        if (permissions & PERMISSION_TRIGGER_ANIMATION)
        {
            llStartAnimation(impact_animation);
            impact_active = TRUE;
            llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_LEFT | CONTROL_RIGHT | CONTROL_UP | CONTROL_DOWN, TRUE, TRUE);
            lock_time = lock_thereshold;
            llSetTimerEvent(timer_thereshold);
        }
    }
}
