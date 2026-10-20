// ath_l3_enter — OnEnter локации L3 «Песчаные пустоши» (сцена 6).
// Переход длится до вечера; ночной марш снижает норму воды на сутки вдвое.

#include "ath_inc_thirst"

void main()
{
    object oPC = GetEnteringObject();
    if (!AthIsPartyCreature(oPC))
        return;
    SetLocalInt(oPC, "ATH_HALF_NEED", 1);
    if (!GetIsPC(oPC) || GetLocalInt(oPC, "ATH_NIGHT_SEEN"))
        return;
    SetLocalInt(oPC, "ATH_NIGHT_SEEN", 1);

    if (GetTimeHour() < 20)
        SetTime(20, 0, 0, 0);
    AddJournalQuestEntry(ATH_QUEST, ATH_J_ROAD, oPC, FALSE, FALSE, FALSE);
    DelayCommand(1.0, FloatingTextStringOnCreature(ATH_TXT_NIGHT, oPC, FALSE));
    DelayCommand(2.0, AthReportWater(oPC));
}
