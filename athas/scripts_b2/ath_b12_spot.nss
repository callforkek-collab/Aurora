// ath_b12_spot — OnEnter триггера у кустов (карточка 12): Мариста шипит и заводит разговор.

#include "ath_inc_b2"

void main()
{
    object oPC = GetEnteringObject();
    object oMarista = GetObjectByTag(ATH_TAG_MARISTA);
    if (!GetIsPC(oPC) || !GetIsObjectValid(oMarista) || GetIsDead(oMarista)
        || GetIsEnemy(oPC, oMarista) || GetLocalInt(oPC, "ATH_SLV_MET"))
        return;
    SetLocalInt(oPC, "ATH_SLV_MET", 1);
    AssignCommand(oMarista, ClearAllActions());
    AssignCommand(oMarista, SpeakString(ATH_TXT2_SLAVE_HUSH));
    AssignCommand(oMarista, ActionStartConversation(oPC, ATH_DLG_SLAVES, FALSE, FALSE));
}
