// ath_s1_loop — OnUsed плейсибла «Костяная петля» в трюме (сцена 1).
// Первый успех: петля трещит, приходит охранник. Второй: игрок свободен, начинается нападение.

#include "ath_inc_const"
#include "ath_inc_text"

void main()
{
    object oPC = GetLastUsedBy();
    object oModule = GetModule();

    if (GetLocalInt(oModule, "ATH_S2") || !GetLocalInt(oPC, "ATH_SHACKLED"))
    {
        FloatingTextStringOnCreature(ATH_TXT_LOOP_LATE, oPC, FALSE);
        return;
    }

    int nRoll = d20() + GetAbilityModifier(ABILITY_STRENGTH, oPC);
    SendMessageToPC(oPC, ATH_TXT_LOOP_ROLL + IntToString(nRoll) + ATH_TXT_LOOP_VS + IntToString(ATH_DC_LOOP));
    if (nRoll < ATH_DC_LOOP)
    {
        FloatingTextStringOnCreature(ATH_TXT_LOOP_FAIL, oPC, FALSE);
        return;
    }

    int nBroken = GetLocalInt(oPC, "ATH_LOOP_BROKEN") + 1;
    SetLocalInt(oPC, "ATH_LOOP_BROKEN", nBroken);
    if (nBroken == 1)
    {
        FloatingTextStringOnCreature(ATH_TXT_LOOP_CRACK, oPC, FALSE);
        object oGuard = GetObjectByTag(ATH_TAG_HOLD_GUARD);
        if (GetIsObjectValid(oGuard))
        {
            AssignCommand(oGuard, ClearAllActions());
            AssignCommand(oGuard, ActionMoveToObject(oPC, TRUE, 2.0));
            AssignCommand(oGuard, ActionSpeakString(ATH_TXT_GUARD_RESHACKLE));
        }
        return;
    }

    DeleteLocalInt(oPC, "ATH_SHACKLED");
    FloatingTextStringOnCreature(ATH_TXT_LOOP_FREE, oPC, FALSE);
    ExecuteScript("ath_s2_attack", oModule);
}
