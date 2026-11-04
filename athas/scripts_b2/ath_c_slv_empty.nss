// ath_c_slv_empty — условие «Вернулся с пустыми руками»: сделка есть, герой побывал в лагере.

#include "ath_inc_b2"

int StartingConditional()
{
    object oModule = GetModule();
    object oPC = GetPCSpeaker();
    return GetLocalInt(oModule, "ATH_SLV_DEAL") && !GetLocalInt(oModule, "ATH_SLV_DONE")
        && GetLocalInt(oPC, "ATH_CAMP_TRIED") && AthCountTagged(oPC, ATH_TAG_SKIN) == 0;
}
