// ath_b2_daily — вызывается из ath_mod_hb в начале новых суток (OBJECT_SELF = герой).
// Яйцо королевы вылупляется через 5 суток и ест 1d4 Тел в день навсегда;
// в коконе змей пьёт 1 Тел в сутки, после освобождения потеря уходит по 1 в сутки.

#include "ath_inc_b2"

void AthApplyTagged(object oPC, string sTag, int nLoss)
{
    AthRemoveTagged(oPC, sTag);
    if (nLoss > 0)
    {
        effect eLoss = TagEffect(SupernaturalEffect(EffectAbilityDecrease(ABILITY_CONSTITUTION, nLoss)), sTag);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLoss, oPC);
    }
}

void main()
{
    object oPC = OBJECT_SELF;
    int nToday = GetLocalInt(GetModule(), "ATH_DAYNUM") + 1;

    int nEgg = GetLocalInt(oPC, "ATH_EGG_DAY");
    if (nEgg > 0 && nToday - nEgg >= ATH_EGG_HATCH_DAYS)
    {
        int nLarva = GetLocalInt(oPC, "ATH_LARVA_LOSS") + d4();
        SetLocalInt(oPC, "ATH_LARVA_LOSS", nLarva);
        AthApplyTagged(oPC, "ATH_LARVA", nLarva);
        SendMessageToPC(oPC, ATH_TXT2_LARVA);
    }

    int nCocoon = GetLocalInt(oPC, "ATH_COCOON_LOSS");
    if (GetLocalInt(oPC, "ATH_IN_COCOON"))
    {
        nCocoon++;
        SendMessageToPC(oPC, ATH_TXT2_COCOON_SIP);
    }
    else if (nCocoon > 0)
        nCocoon--;
    SetLocalInt(oPC, "ATH_COCOON_LOSS", nCocoon);
    AthApplyTagged(oPC, "ATH_COCOON", nCocoon);
}
