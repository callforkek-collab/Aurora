// ath_l2_enter — OnEnter локации L2 «Пески у повозки» (сцены 3–4).
// Помечает локацию как жаркую; при первом выходе из повозки к игроку идёт вождь Джура-Дай.

#include "ath_inc_thirst"

void main()
{
    object oPC = GetEnteringObject();
    SetLocalInt(OBJECT_SELF, "ATH_HOT", 1);
    if (!GetIsPC(oPC) || GetLocalInt(oPC, "ATH_S3_SEEN"))
        return;
    SetLocalInt(oPC, "ATH_S3_SEEN", 1);

    DelayCommand(1.0, FloatingTextStringOnCreature(ATH_TXT_DESERT, oPC, FALSE));
    AddJournalQuestEntry(ATH_QUEST, ATH_J_ELVES, oPC, FALSE, FALSE, FALSE);

    object oChief = GetObjectByTag(ATH_TAG_CHIEF);
    if (GetIsObjectValid(oChief) && !GetLocalInt(GetModule(), "ATH_WAGON_BURNED"))
    {
        AssignCommand(oChief, ClearAllActions());
        AssignCommand(oChief, ActionMoveToObject(oPC, TRUE, 2.5));
        AssignCommand(oChief, ActionStartConversation(oPC, ATH_DLG_CHIEF, FALSE, FALSE));
    }
}
