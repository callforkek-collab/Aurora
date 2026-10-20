// ath_thirsty_half — Action Taken в ath_dlg_thirsty: «Половину». Убеждение.

#include "ath_inc_s4"

void main()
{
    object oPC = GetPCSpeaker();
    if (!GetIsSkillSuccessful(oPC, SKILL_PERSUADE, ATH_DC_PERSUADE))
    {
        AthThirstyFight(GetArea(OBJECT_SELF));
        return;
    }
    int nWater = AthCountWater(oPC);
    AthTakeWater(oPC, (nWater + 1) / 2, OBJECT_SELF);
    SendMessageToPC(oPC, ATH_TXT_GUARDS_LEAVE);
    AthThirstyLeave(GetArea(OBJECT_SELF), -1);
}
