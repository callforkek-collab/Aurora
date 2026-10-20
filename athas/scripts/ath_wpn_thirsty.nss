// ath_wpn_thirsty — tag-based скрипт оружия жаждущих охранников (тег ath_wpn_thirsty).
// Шаблон: обсидиановый короткий меч со свойством On Hit Cast Spell: OnHit Unique Power.
// Каждое попадание с шансом ATH_SPILL_CHANCE разбивает один кувшин цели.

#include "x2_inc_switches"
#include "ath_inc_thirst"

void main()
{
    if (GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ONHITCAST)
        return;
    object oTarget = GetSpellTargetObject();
    if (GetIsObjectValid(oTarget) && AthCountWater(oTarget) > 0 && d100() <= ATH_SPILL_CHANCE)
    {
        AthTakeWater(oTarget, 1);
        FloatingTextStringOnCreature(ATH_TXT_SPILL, oTarget, FALSE);
    }
}
