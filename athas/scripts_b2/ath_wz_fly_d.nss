// ath_wz_fly_d — OnDeath водоноса над полем куполов (карточка 9): шар лопается о песок.

#include "ath_inc_b2"

void main()
{
    AthTextToPCsIn(GetArea(OBJECT_SELF), ATH_TXT2_FLYER_X);
    ExecuteScript("nw_c2_default7", OBJECT_SELF);
}
