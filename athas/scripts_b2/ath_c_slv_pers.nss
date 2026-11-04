// ath_c_slv_pers — условие реплики «сделка» после «Четверо — уже банда»: Убеждение DC 13.

#include "ath_inc_b2"

int StartingConditional()
{
    return GetIsSkillSuccessful(GetPCSpeaker(), SKILL_PERSUADE, ATH_DC_SLV_PERSUADE);
}
