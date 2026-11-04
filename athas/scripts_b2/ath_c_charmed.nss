// ath_c_charmed — условие в ath_dlg_aara: ааракокра очарована или подчинена (говорит правду).

#include "ath_inc_b2"

int StartingConditional()
{
    return AthHasEffectType(OBJECT_SELF, EFFECT_TYPE_CHARMED)
        || AthHasEffectType(OBJECT_SELF, EFFECT_TYPE_DOMINATED);
}
