// ath_psion_agree — Action Taken в ath_dlg_psion: «Согласен».
// Кандалы сняты, выдан арбалет и 20 обсидиановых болтов.

#include "ath_inc_psion"

void main()
{
    object oPC = GetPCSpeaker();
    AthUnshackle(oPC);
    SetLocalInt(oPC, "ATH_DEFENDER", 1);
    CreateItemOnObject(ATH_RES_XBOW, oPC);
    CreateItemOnObject(ATH_RES_BOLT, oPC, 20);
}
