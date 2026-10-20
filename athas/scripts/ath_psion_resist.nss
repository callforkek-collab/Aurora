// ath_psion_resist — Action Taken в ath_dlg_psion: «Попробуй заставь».
// Спасбросок Воли: успех — псионик отступает, провал — как при отказе.

#include "ath_inc_psion"

void main()
{
    object oPC = GetPCSpeaker();
    if (WillSave(oPC, ATH_DC_PSION_WILL, SAVING_THROW_TYPE_MIND_SPELLS) == 0)
    {
        AthPsionPunish(oPC);
        return;
    }
    FloatingTextStringOnCreature(ATH_TXT_PSION_RESIST, oPC, FALSE);
    AthUnshackle(oPC);
}
