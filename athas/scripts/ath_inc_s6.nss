// ath_inc_s6 — шипы тимириса (сцена 6).
//   ATH_THORNS  сколько шипов сидит в персонаже

#include "ath_inc_thirst"

// Кровотечение по 1 единице за раунд, пока шипы не вытащены.
void AthBleed(object oCreature)
{
    if (GetLocalInt(oCreature, "ATH_THORNS") <= 0 || GetIsDead(oCreature))
        return;
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(1, DAMAGE_TYPE_PIERCING), oCreature);
    FloatingTextStringOnCreature(ATH_TXT_THORNS_BLEED, oCreature, FALSE);
    DelayCommand(6.0, AthBleed(oCreature));
}
