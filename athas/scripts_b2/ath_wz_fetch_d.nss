// ath_wz_fetch_d — OnDeath везера-водоноса из карточки 8.
// Спасён — шар цел; убит героем — птицы уносят шар; убит птицами — шар лопается на героя.

#include "ath_inc_b2"

void main()
{
    object oSelf = OBJECT_SELF;
    object oModule = GetModule();
    location lHere = GetLocation(oSelf);
    object oArea = GetArea(oSelf);

    if (GetLocalInt(oSelf, "ATH_RESCUED"))
    {
        CreateObject(OBJECT_TYPE_ITEM, ATH_RES_WAX_WATER, lHere);
        AthTextToPCsIn(oArea, ATH_TXT2_WZ_SAVED);
    }
    else
    {
        object oKiller = GetLastKiller();
        if (GetIsPC(oKiller) || GetIsPC(GetMaster(oKiller)))
        {
            object oObject = GetFirstObjectInArea(oArea);
            while (GetIsObjectValid(oObject))
            {
                if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && !GetIsDead(oObject)
                    && AthTagStarts(oObject, ATH_TAG_AARA))
                {
                    AssignCommand(oObject, ClearAllActions(TRUE));
                    AssignCommand(oObject, ActionMoveAwayFromLocation(lHere, TRUE, 40.0));
                    DestroyObject(oObject, 6.0);
                }
                oObject = GetNextObjectInArea(oArea);
            }
            AthTextToPCsIn(oArea, ATH_TXT2_AARA_TAKE);
        }
        else
        {
            object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
            if (GetIsObjectValid(oPC) && GetDistanceBetween(oPC, oSelf) < 15.0)
            {
                FloatingTextStringOnCreature(ATH_TXT2_WZ_BURST, oPC, FALSE);
                AthDrink(oPC);
            }
        }
    }
    SetLocalInt(oModule, "ATH_B8_DONE", 1);
    ExecuteScript("nw_c2_default7", oSelf);
}
