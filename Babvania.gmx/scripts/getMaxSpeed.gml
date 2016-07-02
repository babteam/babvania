///Get the Player's Max Speed

if argument0.isSprinting
    return PLAYER_SPEED_SPRINT;

switch argument0.diaperState {
    case PLAYER_DIAPER_DRY:
        return PLAYER_SPEED_DRY;
    case PLAYER_DIAPER_WET:
        return PLAYER_SPEED_WET;
    case PLAYER_DIAPER_FULL:
        return PLAYER_SPEED_FULL;
}
