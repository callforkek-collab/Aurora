// ath_s6_pool — OnUsed «пруда» в центре чащи тимириса: это не вода.

#include "ath_inc_text"

void main()
{
    FloatingTextStringOnCreature(ATH_TXT_POOL, GetLastUsedBy(), FALSE);
}
