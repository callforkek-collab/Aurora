// ath_end — OnEnter триггера у юго-западного края L3: рассвет, конец среза.
// Переход времени через полночь запускает суточную проверку воды в ath_mod_hb.

#include "ath_inc_thirst"

void AthDawn(object oPC)
{
    SetTime(6, 0, 0, 0);
    FadeFromBlack(oPC, FADE_SPEED_SLOW);
    AddJournalQuestEntry(ATH_QUEST, ATH_J_DAWN, oPC, FALSE, FALSE, FALSE);
    DelayCommand(2.0, FloatingTextStringOnCreature(ATH_TXT_DAWN, oPC, FALSE));
}

void main()
{
    object oPC = GetEnteringObject();
    if (!GetIsPC(oPC) || GetLocalInt(oPC, "ATH_END"))
        return;
    SetLocalInt(oPC, "ATH_END", 1);
    FadeToBlack(oPC, FADE_SPEED_SLOW);
    DelayCommand(4.0, AthDawn(oPC));
}
