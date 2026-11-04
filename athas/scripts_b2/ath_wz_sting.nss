// ath_wz_sting — tag-based жало солдата-везера (On Hit: Unique Power).
// Стойкость DC 12, иначе через 1d4 раунда паралич на 1d3 раунда (в оригинале — на дни).

#include "x2_inc_switches"
#include "ath_inc_b2"

void AthPoisonClear(object oTarget)
{
    DeleteLocalInt(oTarget, "ATH_WZ_POISONED");
}

void AthParalyze(object oTarget, float fDuration)
{
    if (GetIsDead(oTarget))
        return;
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectParalyze(), oTarget, fDuration);
    FloatingTextStringOnCreature(ATH_TXT2_PARALYZED, oTarget, FALSE);
    DelayCommand(fDuration, AthPoisonClear(oTarget));
}

void main()
{
    if (GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ONHITCAST)
        return;
    object oTarget = GetSpellTargetObject();
    if (!GetIsObjectValid(oTarget) || GetLocalInt(oTarget, "ATH_WZ_POISONED"))
        return;
    if (FortitudeSave(oTarget, ATH_DC_WZ_POISON, SAVING_THROW_TYPE_POISON) != 0)
        return;
    SetLocalInt(oTarget, "ATH_WZ_POISONED", 1);
    FloatingTextStringOnCreature(ATH_TXT2_NUMB, oTarget, FALSE);
    AssignCommand(oTarget, DelayCommand(RoundsToSeconds(d4()), AthParalyze(oTarget, RoundsToSeconds(d3()))));
}
