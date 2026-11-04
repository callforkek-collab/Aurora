// ath_boil — OnUsed кострища у оазиса (карточка 15): выпаривание воды.
// Нужны горшок и топливо (уголь или хворост), уходит час. Проверка Инт с -4 тайная:
// при провале получается вода с тем же названием, но отравленная.

#include "ath_inc_b2"

void main()
{
    object oPC = GetLastUsedBy();
    int bPot = GetIsObjectValid(GetItemPossessedBy(oPC, ATH_TAG_POT));
    string sFuel = "";
    if (AthCountTagged(oPC, ATH_TAG_CHARCOAL) > 0)
        sFuel = ATH_TAG_CHARCOAL;
    else if (AthCountTagged(oPC, ATH_TAG_FUEL) > 0)
        sFuel = ATH_TAG_FUEL;
    if (!bPot || sFuel == "")
    {
        FloatingTextStringOnCreature(ATH_TXT2_BOIL_NEED, oPC, FALSE);
        return;
    }
    AthTakeTagged(oPC, sFuel, 1);
    AthAdvanceHours(1);
    if (d20() + GetAbilityModifier(ABILITY_INTELLIGENCE, oPC) >= ATH_DC_BOIL)
        CreateItemOnObject(ATH_RES_BOILED, oPC, ATH_BOIL_QUARTS);
    else
        CreateItemOnObject(ATH_RES_BOILED_X, oPC, ATH_BOIL_QUARTS);
    FloatingTextStringOnCreature(ATH_TXT2_BOIL, oPC, FALSE);
}
