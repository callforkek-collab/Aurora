// ath_slv_news — Action Taken после «Ну хоть живой»: новости про Клед без дележа.

#include "ath_inc_b2"

void main()
{
    SetLocalInt(GetModule(), "ATH_SLV_DONE", 1);
    AthJournal2(GetPCSpeaker(), ATH_J2_KLED);
}
