// ath_slv_fight — Action Taken: бывшие рабы нападают.

#include "ath_inc_b2"

void main()
{
    SetLocalInt(GetModule(), "ATH_SLV_DONE", 1);
    AthMakeHostile(GetArea(OBJECT_SELF), ATH_TAG_SLAVE, GetPCSpeaker());
}
