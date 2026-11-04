// ath_c_sneaky — условие в ath_dlg_slaves: Скрытность или Бесшумность от ATH_SNEAK_RANKS.

#include "ath_inc_b2"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    return GetSkillRank(SKILL_HIDE, oPC) >= ATH_SNEAK_RANKS
        || GetSkillRank(SKILL_MOVE_SILENTLY, oPC) >= ATH_SNEAK_RANKS;
}
