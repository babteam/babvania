///Gets the recovery value for the player

switch argument0.diaperState {
    case PLAYER_DIAPER_DRY:
        return PLAYER_REC_DRY;
    case PLAYER_DIAPER_WET:
        return PLAYER_REC_WET;
    case PLAYER_DIAPER_FULL:
        return PLAYER_DIAPER_FULL;
}
