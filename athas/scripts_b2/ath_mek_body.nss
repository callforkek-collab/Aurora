// ath_mek_body — OnUsed тела мёртвого мекиллота (карточка 14).

#include "ath_inc_b2"

void main()
{
    FloatingTextStringOnCreature(ATH_TXT2_MEK_BODY, GetLastUsedBy(), FALSE);
}
