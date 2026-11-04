// ath_slv_share — Action Taken «Ваша половина»: бывшие рабы забирают половину бурдюков
// (округление в их пользу) и рассказывают про Клед.

#include "ath_inc_b2"

void main()
{
    object oPC = GetPCSpeaker();
    int nSkins = AthCountTagged(oPC, ATH_TAG_SKIN);
    AthTakeTagged(oPC, ATH_TAG_SKIN, (nSkins + 1) / 2);
    SetLocalInt(GetModule(), "ATH_SLV_DONE", 1);
    AthJournal2(oPC, ATH_J2_KLED);
}
