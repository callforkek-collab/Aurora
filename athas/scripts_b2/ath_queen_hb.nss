// ath_queen_hb — OnHeartbeat королевы: пока она разбужена и жива, каждый раунд
// входит солдат, всего не больше ATH_QUEEN_REINF.

#include "ath_inc_b2"

void main()
{
    object oSelf = OBJECT_SELF;
    if (GetLocalInt(oSelf, "ATH_WOKEN") && !GetIsDead(oSelf) && !GetLocalInt(GetModule(), "ATH_SMOKE_USED"))
    {
        int nCalled = GetLocalInt(oSelf, "ATH_CALLED");
        if (nCalled < ATH_QUEEN_REINF)
        {
            SetLocalInt(oSelf, "ATH_CALLED", nCalled + 1);
            object oSoldier = CreateObject(OBJECT_TYPE_CREATURE, ATH_RES_WZ_SOLD,
                                           GetLocation(GetWaypointByTag(ATH_WP_BROOD_IN)));
            object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oSelf);
            if (GetIsObjectValid(oPC))
                AssignCommand(oSoldier, ActionAttack(oPC));
        }
    }
    ExecuteScript("nw_c2_default1", oSelf);
}
