// ath_aara_dmg — OnDamaged ааракокры. При половине HP улетает и потом мстит издалека.

#include "ath_inc_aara"

void main()
{
    object oSelf = OBJECT_SELF;
    if (!GetLocalInt(oSelf, "ATH_FLED") && GetCurrentHitPoints(oSelf) * 2 < GetMaxHitPoints(oSelf))
    {
        SetLocalInt(oSelf, "ATH_FLED", 1);
        SetLocalInt(GetModule(), "ATH_AARA_FLED", 1);
        AthTextToPCsIn(GetArea(oSelf), ATH_TXT2_AARA_FLEE);
        ClearAllActions(TRUE);
        ActionMoveAwayFromObject(GetLastDamager(), TRUE, 40.0);
        DestroyObject(oSelf, 6.0);
        object oArea = GetArea(oSelf);
        AssignCommand(GetModule(), DelayCommand(1.0, AthAaraCheck(oArea)));
        return;
    }
    ExecuteScript("nw_c2_default6", oSelf);
}
