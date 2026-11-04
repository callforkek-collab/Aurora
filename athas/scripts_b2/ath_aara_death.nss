// ath_aara_death — OnDeath ааракокры.

#include "ath_inc_aara"

void main()
{
    object oArea = GetArea(OBJECT_SELF);
    AssignCommand(GetModule(), DelayCommand(1.0, AthAaraCheck(oArea)));
    ExecuteScript("nw_c2_default7", OBJECT_SELF);
}
