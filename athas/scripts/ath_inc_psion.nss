// ath_inc_psion — общие действия диалога психоника (ath_dlg_psion).

#include "ath_inc_const"
#include "ath_inc_text"

void AthUnshackle(object oPC)
{
    DeleteLocalInt(oPC, "ATH_SHACKLED");
    FloatingTextStringOnCreature(ATH_TXT_UNSHACKLED, oPC, FALSE);
}

// Отказ или проигранная схватка воль: боль, но дверь остаётся открытой.
void AthPsionPunish(object oPC)
{
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEAD_MIND), oPC);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d4(), DAMAGE_TYPE_MAGICAL), oPC);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDazed(), oPC, 6.0);
    FloatingTextStringOnCreature(ATH_TXT_PSION_PAIN, oPC, FALSE);
    AthUnshackle(oPC);
}
