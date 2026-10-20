// ath_c_elf — Text Appears When в ath_dlg_chief: ветки только для персонажа-эльфа.

int StartingConditional()
{
    return GetRacialType(GetPCSpeaker()) == RACIAL_TYPE_ELF;
}
