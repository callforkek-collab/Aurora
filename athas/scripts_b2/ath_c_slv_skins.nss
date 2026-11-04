// ath_c_slv_skins — условие «Вернулся с бурдюками»: сделка есть, бурдюки у героя.

#include "ath_inc_b2"

int StartingConditional()
{
    object oModule = GetModule();
    return GetLocalInt(oModule, "ATH_SLV_DEAL") && !GetLocalInt(oModule, "ATH_SLV_DONE")
        && AthCountTagged(GetPCSpeaker(), ATH_TAG_SKIN) > 0;
}
