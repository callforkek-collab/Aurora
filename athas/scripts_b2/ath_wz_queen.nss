// ath_wz_queen — tag-based жало королевы (On Hit: Unique Power).
// +1d6 урона; Стойкость DC 14, иначе в героя отложено яйцо (вылупится через 5 суток).

#include "x2_inc_switches"
#include "ath_inc_b2"

void main()
{
    if (GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ONHITCAST)
        return;
    object oTarget = GetSpellTargetObject();
    if (!GetIsObjectValid(oTarget))
        return;
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(), DAMAGE_TYPE_PIERCING), oTarget);
    if (GetLocalInt(oTarget, "ATH_EGG_DAY")
        || FortitudeSave(oTarget, ATH_DC_EGG, SAVING_THROW_TYPE_POISON) != 0)
        return;
    // +1, чтобы день 0 отличался от «яйца нет».
    SetLocalInt(oTarget, "ATH_EGG_DAY", GetLocalInt(GetModule(), "ATH_DAYNUM") + 1);
    CreateItemOnObject(ATH_RES_EGG_CUT, oTarget);
    FloatingTextStringOnCreature(ATH_TXT2_EGG, oTarget, FALSE);
    AthJournal2(oTarget, ATH_J2_EGG);
}
