// ath_chain_exit — OnExit триггера вокруг места привязи в трюме.
// Пока на персонаже кандалы, он не может отойти от стены.

#include "ath_inc_const"
#include "ath_inc_text"

void main()
{
    object oPC = GetExitingObject();
    if (!GetLocalInt(oPC, "ATH_SHACKLED"))
        return;
    AssignCommand(oPC, ClearAllActions());
    AssignCommand(oPC, JumpToObject(GetWaypointByTag(ATH_WP_CHAIN)));
    FloatingTextStringOnCreature(ATH_TXT_CHAIN, oPC, FALSE);
}
