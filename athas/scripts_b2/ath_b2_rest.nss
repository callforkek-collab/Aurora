// ath_b2_rest — вызывается из ath_rest (OBJECT_SELF = герой, ATH_REST_EVENT = тип события).
// Начало отдыха ночью под открытым небом с водой — приходит змей (карточка 13).
// Конец отдыха после чая из ипра — минус 1 к штрафу обезвоживания или +1 HP.

#include "ath_inc_b2"

void main()
{
    object oPC = OBJECT_SELF;
    int nType = GetLocalInt(oPC, "ATH_REST_EVENT");

    if (nType == REST_EVENTTYPE_REST_STARTED)
    {
        if (GetLocalInt(GetArea(oPC), "ATH_OUTDOOR") && GetIsNight()
            && !GetLocalInt(GetModule(), "ATH_WYRM_DONE")
            && AthCountAllWater(oPC) >= ATH_WYRM_MIN_WATER)
            ExecuteScript("ath_wyrm_go", oPC);
        return;
    }

    if (nType == REST_EVENTTYPE_REST_FINISHED && GetLocalInt(oPC, "ATH_TEA"))
    {
        DeleteLocalInt(oPC, "ATH_TEA");
        int nLoss = GetLocalInt(oPC, "ATH_DRY_LOSS");
        if (nLoss > 0)
        {
            nLoss--;
            AthRemoveTagged(oPC, "ATH_DEHYDRATION");
            if (nLoss > 0)
            {
                effect eLoss = TagEffect(SupernaturalEffect(EffectAbilityDecrease(ABILITY_CONSTITUTION, nLoss)), "ATH_DEHYDRATION");
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLoss, oPC);
            }
            SetLocalInt(oPC, "ATH_DRY_LOSS", nLoss);
        }
        else
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(1), oPC);
        SendMessageToPC(oPC, ATH_TXT2_TEA_REST);
    }
}
