// ath_wyrm_hb — OnHeartbeat шёлкового змея (карточка 13).
// Невидимым пьёт по 3 галлона за раунд; выпив 15 галлонов, или если герой проснулся, — нападает.
// С половиной HP уползает в логово.

#include "ath_inc_b2"

void AthWyrmReveal(object oWyrm, object oPrey)
{
    SetLocalInt(oWyrm, "ATH_ATTACK", 1);
    AthRemoveTagged(oWyrm, "ATH_WYRM_HIDE");
    ChangeToStandardFaction(oWyrm, STANDARD_FACTION_HOSTILE);
    AssignCommand(oWyrm, ActionAttack(oPrey));
    FloatingTextStringOnCreature(ATH_TXT2_WYRM_SEEN, oPrey, FALSE);
    AthJournal2(oPrey, ATH_J2_WYRM);
}

void main()
{
    object oWyrm = OBJECT_SELF;
    object oPrey = GetLocalObject(oWyrm, "ATH_PREY");

    if (GetLocalInt(oWyrm, "ATH_ATTACK"))
    {
        if (GetCurrentHitPoints(oWyrm) * 2 < GetMaxHitPoints(oWyrm) && !GetLocalInt(oWyrm, "ATH_FLED"))
        {
            SetLocalInt(oWyrm, "ATH_FLED", 1);
            ClearAllActions(TRUE);
            object oLair = GetWaypointByTag(ATH_WP_LAIR);
            if (GetArea(oLair) == GetArea(oWyrm))
                ActionMoveToObject(oLair, TRUE);
            else
                ActionJumpToObject(oLair);
            ChangeToStandardFaction(oWyrm, STANDARD_FACTION_COMMONER);
            return;
        }
        ExecuteScript("nw_c2_default1", oWyrm);
        return;
    }

    if (!GetIsObjectValid(oPrey) || GetIsDead(oPrey))
    {
        DestroyObject(oWyrm);
        return;
    }
    int nDrunk = GetLocalInt(oWyrm, "ATH_DRUNK_Q") + AthDrainWater(oPrey, ATH_WYRM_SIP);
    SetLocalInt(oWyrm, "ATH_DRUNK_Q", nDrunk);
    if (d2() == 1)
        SendMessageToPC(oPrey, ATH_TXT2_WYRM_SIP);
    if (nDrunk >= ATH_WYRM_MAX || AthCountAllWater(oPrey) == 0 || !GetIsResting(oPrey))
        AthWyrmReveal(oWyrm, oPrey);
}
