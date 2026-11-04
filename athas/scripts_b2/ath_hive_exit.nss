// ath_hive_exit — OnExit локации «Улей»: штраф тесноты снимается.

#include "ath_inc_b2"

void main()
{
    AthRemoveTagged(GetExitingObject(), "ATH_TUNNEL");
}
