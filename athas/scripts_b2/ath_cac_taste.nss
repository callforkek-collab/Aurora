// ath_cac_taste — OnUsed «Пурпурного шара» (карточка 7). Сок — яд:
// Знание DC 15 при первой попытке предупреждает, иначе -d4 Тел на 2 часа.

#include "ath_inc_b2"

void main()
{
    object oPC = GetLastUsedBy();
    if (!GetLocalInt(oPC, "ATH_CAC_WARNED") && GetIsSkillSuccessful(oPC, SKILL_LORE, ATH_DC_LORE))
    {
        SetLocalInt(oPC, "ATH_CAC_WARNED", 1);
        FloatingTextStringOnCreature(ATH_TXT2_CAC_KNOW, oPC, FALSE);
        return;
    }
    effect eSick = EffectAbilityDecrease(ABILITY_CONSTITUTION, d4());
    eSick = TagEffect(SupernaturalEffect(eSick), "ATH_CACTUS");
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSick, oPC, HoursToSeconds(2));
    FloatingTextStringOnCreature(ATH_TXT2_CAC_SICK, oPC, FALSE);
}
