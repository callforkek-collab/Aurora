// ath_domes_hb — OnHeartbeat локации «Поле куполов» (карточка 9):
// днём время от времени над головой пролетает везер-водонос.

#include "ath_inc_b2"

void main()
{
    int nBeat = GetLocalInt(OBJECT_SELF, "ATH_BEAT") + 1;
    SetLocalInt(OBJECT_SELF, "ATH_BEAT", nBeat);
    if (nBeat % ATH_FLYER_EVERY_HB == 0 && GetIsDay())
        AthTextToPCsIn(OBJECT_SELF, ATH_TXT2_FLYER);
}
