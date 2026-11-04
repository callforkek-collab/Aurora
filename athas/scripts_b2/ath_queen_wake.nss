// ath_queen_wake — OnDisturbed сот (контейнер) и OnUsed тел в выводковой камере (карточка 11).
// Королева становится враждебной.

#include "ath_inc_b2"

void main()
{
    object oPC = GetLastDisturbed();
    if (!GetIsObjectValid(oPC))
        oPC = GetLastUsedBy();
    object oQueen = GetObjectByTag(ATH_TAG_QUEEN);
    if (!GetIsObjectValid(oQueen) || GetIsDead(oQueen) || GetLocalInt(oQueen, "ATH_WOKEN"))
        return;
    SetLocalInt(oQueen, "ATH_WOKEN", 1);
    ChangeToStandardFaction(oQueen, STANDARD_FACTION_HOSTILE);
    AssignCommand(oQueen, ActionAttack(oPC));
    FloatingTextStringOnCreature(ATH_TXT2_QUEEN_UP, oPC, FALSE);
}
