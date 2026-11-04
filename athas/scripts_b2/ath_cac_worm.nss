// ath_cac_worm — OnDamaged «Шевелящейся массы» (карточка 7).
// Каждый удар выпускает червя: Рефлекс DC 14, иначе опутан и душится 1d6 за раунд.

#include "ath_inc_b2"

void AthWormSqueeze(object oVictim, int nRounds)
{
    if (nRounds <= 0 || GetIsDead(oVictim) || !AthHasEffectType(oVictim, EFFECT_TYPE_ENTANGLE))
        return;
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(), DAMAGE_TYPE_BLUDGEONING), oVictim);
    DelayCommand(6.0, AthWormSqueeze(oVictim, nRounds - 1));
}

void main()
{
    object oVictim = GetLastDamager();
    if (!GetIsObjectValid(oVictim))
        return;

    if (ReflexSave(oVictim, ATH_DC_WORM, SAVING_THROW_TYPE_NONE) == 0)
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectEntangle(), oVictim, RoundsToSeconds(ATH_WORM_ROUNDS));
        FloatingTextStringOnCreature(ATH_TXT2_WORM_GRAB, oVictim, FALSE);
        AssignCommand(oVictim, DelayCommand(6.0, AthWormSqueeze(oVictim, ATH_WORM_ROUNDS)));
    }
    else
        FloatingTextStringOnCreature(ATH_TXT2_WORM_MISS, oVictim, FALSE);

    if (GetIsPC(oVictim) && !GetLocalInt(oVictim, "ATH_GOT_ROPE"))
    {
        SetLocalInt(oVictim, "ATH_GOT_ROPE", 1);
        CreateItemOnObject(ATH_RES_WORM_ROPE, oVictim);
        DelayCommand(2.0, SendMessageToPC(oVictim, ATH_TXT2_WORM_ROPE));
    }
}
