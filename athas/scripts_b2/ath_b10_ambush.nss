// ath_b10_ambush — OnEnter триггера в зале F (карточка 10): солдат из бокового туннеля.

#include "ath_inc_b2"

void main()
{
    object oPC = GetEnteringObject();
    if (!AthIsPartyCreature(oPC) || GetLocalInt(OBJECT_SELF, "ATH_DONE") || GetLocalInt(GetModule(), "ATH_SMOKE_USED"))
        return;
    SetLocalInt(OBJECT_SELF, "ATH_DONE", 1);
    object oSoldier = CreateObject(OBJECT_TYPE_CREATURE, ATH_RES_WZ_SOLD, GetLocation(GetWaypointByTag(ATH_WP_AMBUSH)));
    AssignCommand(oSoldier, ActionAttack(oPC));
}
