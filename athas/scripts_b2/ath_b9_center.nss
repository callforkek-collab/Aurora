// ath_b9_center — OnEnter триггера у центрального купола (карточка 9):
// из лаза выползает рабочий везер и бросается на героя.

#include "ath_inc_b2"

void main()
{
    object oPC = GetEnteringObject();
    if (!GetIsPC(oPC) || GetLocalInt(OBJECT_SELF, "ATH_DONE"))
        return;
    SetLocalInt(OBJECT_SELF, "ATH_DONE", 1);
    object oWorker = CreateObject(OBJECT_TYPE_CREATURE, ATH_RES_WZ_WORKER,
                                  GetLocation(GetWaypointByTag(ATH_WP_DOME_C)));
    AssignCommand(oWorker, ActionAttack(oPC));
    AthJournal2(oPC, ATH_J2_HIVE);
}
