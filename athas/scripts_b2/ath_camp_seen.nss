// ath_camp_seen — OnPerception неспящей охраны лагеря: увидел героя внутри лагеря — тревога.

#include "ath_inc_b2"

void main()
{
    object oSeen = GetLastPerceived();
    if (GetLastPerceptionSeen() && GetIsPC(oSeen) && GetLocalInt(oSeen, "ATH_IN_CAMP"))
        AthCampAlarm(oSeen);
    ExecuteScript("nw_c2_default2", OBJECT_SELF);
}
