// ath_c_caster — условие в ath_dlg_slaves: герой умеет творить заклинания.

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    return GetLevelByClass(CLASS_TYPE_WIZARD, oPC) > 0 || GetLevelByClass(CLASS_TYPE_SORCERER, oPC) > 0
        || GetLevelByClass(CLASS_TYPE_CLERIC, oPC) > 0 || GetLevelByClass(CLASS_TYPE_DRUID, oPC) > 0
        || GetLevelByClass(CLASS_TYPE_BARD, oPC) > 0;
}
