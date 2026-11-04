// ath_hive_enter — OnEnter локации «Улей» (карточка 10).
// Низкие туннели: -2 к атаке всем, кроме полуросликов, гномов и дварфов.

#include "ath_inc_b2"

void main()
{
    object oEnter = GetEnteringObject();
    if (!AthIsPartyCreature(oEnter))
        return;
    if (!AthIsSmallRace(oEnter) && !AthHasTagged(oEnter, "ATH_TUNNEL"))
    {
        effect eCramped = TagEffect(SupernaturalEffect(EffectAttackDecrease(ATH_TUNNEL_PENALTY)), "ATH_TUNNEL");
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eCramped, oEnter);
    }
    if (GetIsPC(oEnter) && !GetLocalInt(oEnter, "ATH_HIVE_SEEN"))
    {
        SetLocalInt(oEnter, "ATH_HIVE_SEEN", 1);
        DelayCommand(1.0, FloatingTextStringOnCreature(ATH_TXT2_HIVE, oEnter, FALSE));
        AthJournal2(oEnter, ATH_J2_HIVE);
    }
}
