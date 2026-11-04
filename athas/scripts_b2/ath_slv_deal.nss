// ath_slv_deal — Action Taken «Договорились»: сделка пятьдесят на пятьдесят.

#include "ath_inc_b2"

void main()
{
    SetLocalInt(GetModule(), "ATH_SLV_DEAL", 1);
    AthJournal2(GetPCSpeaker(), ATH_J2_DEAL);
}
