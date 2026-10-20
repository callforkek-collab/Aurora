// ath_thirsty_scare — Action Taken в ath_dlg_thirsty: «Только подойди». Запугивание.

#include "ath_inc_s4"

void main()
{
    object oPC = GetPCSpeaker();
    if (!GetIsSkillSuccessful(oPC, SKILL_INTIMIDATE, ATH_DC_INTIMIDATE))
    {
        AthThirstyFight(GetArea(OBJECT_SELF));
        return;
    }
    SendMessageToPC(oPC, ATH_TXT_GUARDS_LEAVE);
    AthThirstyLeave(GetArea(OBJECT_SELF), -1);
}
