// ath_herb — OnUsed фиолетовых листьев на мостике (карточка 15): метелинок, улика против эльфов.

#include "ath_inc_b2"

void main()
{
    object oPC = GetLastUsedBy();
    if (GetIsSkillSuccessful(oPC, SKILL_LORE, ATH_DC_LORE))
    {
        FloatingTextStringOnCreature(ATH_TXT2_HERB_KNOW, oPC, FALSE);
        AthJournal2(oPC, ATH_J2_POISON);
    }
    else
        FloatingTextStringOnCreature(ATH_TXT2_HERB, oPC, FALSE);
}
