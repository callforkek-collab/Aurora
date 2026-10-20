// ath_thirsty_give — Action Taken в ath_dlg_thirsty: «Держи». Вся вода уходит охране.

#include "ath_inc_s4"

void main()
{
    object oPC = GetPCSpeaker();
    AthTakeWater(oPC, AthCountWater(oPC), OBJECT_SELF);
    SendMessageToPC(oPC, ATH_TXT_GUARDS_LEAVE);
    AthThirstyLeave(GetArea(OBJECT_SELF), -1);
}
