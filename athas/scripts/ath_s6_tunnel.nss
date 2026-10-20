// ath_s6_tunnel — OnEnter триггера на середине тоннеля в чаще тимириса.
// 1d6×10 шипов, урон = шипы/10, затем кровотечение. Выдаётся предмет «Вытащить шипы».

#include "ath_inc_s6"

void main()
{
    object oVictim = GetEnteringObject();
    if (!AthIsPartyCreature(oVictim) || GetLocalInt(oVictim, "ATH_THORNS") > 0)
        return;

    int nThorns = d6() * 10;
    SetLocalInt(oVictim, "ATH_THORNS", nThorns);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SPIKE_TRAP), oVictim);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nThorns / 10, DAMAGE_TYPE_PIERCING), oVictim);
    FloatingTextStringOnCreature(ATH_TXT_THORNS + IntToString(nThorns) + ATH_TXT_THORNS_N, oVictim, FALSE);

    if (!GetIsObjectValid(GetItemPossessedBy(oVictim, ATH_TAG_THORNS)))
        CreateItemOnObject(ATH_RES_THORNS, oVictim);
    if (GetIsPC(oVictim))
        AddJournalQuestEntry(ATH_QUEST, ATH_J_TIMIRIS, oVictim, FALSE, FALSE, FALSE);

    AssignCommand(oVictim, DelayCommand(6.0, AthBleed(oVictim)));
}
