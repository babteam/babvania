///Player Movement

//Revert vspeed. As vspeed should not change unless you are on a slope or falling, resets it to zero if not falling (slope handled later on)
if (!isFalling)
    vspeed = 0;

//Sprint check
if (keyboard_check(global.settingsID.key_sprint) && sprintMeter >= PLAYER_SPRINT_MIN)
{
    isSprinting = true;
}

//Left/right movement
if (keyboard_check(global.settingsID.key_right) && !keyboard_check(global.settingsID.key_left)){ //Right
    sprite_index = standR;
    if (hspeed + PLAYER_ACCEL < getMaxSpeed(self)) {
        hspeed += PLAYER_ACCEL;
    } else {
        hspeed = getMaxSpeed(self);
    }
} else if (!keyboard_check(global.settingsID.key_right) && keyboard_check(global.settingsID.key_left)) { //Left
    sprite_index = standL;
    if (hspeed - PLAYER_ACCEL > -1*getMaxSpeed(self)) {
        hspeed -= PLAYER_ACCEL;
    } else {
        hspeed = -1*getMaxSpeed(self);
    }
} else if (hspeed != 0) { //Stopping/released keys
    isSprinting = false;
    if (hspeed > PLAYER_ACCEL) {
        hspeed -= PLAYER_ACCEL;
    } else if (hspeed < -1*PLAYER_ACCEL) {
        hspeed += PLAYER_ACCEL;
    } else if ((hspeed > 0 && hspeed <=PLAYER_ACCEL) || (hspeed < 0 && hspeed >=-PLAYER_ACCEL)) {
        hspeed = 0; //Set speed to zero if below a certain point
    }
}

/*//Slope detection
//Up
if(!isFalling && !place_free(x+hspeed, y+vspeed) && place_free(x+hspeed, y-PLAYER_SLOPE_HEIGHT*hspeed-1)) {
    for ( i = 0; i <= PLAYER_SLOPE_HEIGHT*hspeed-1; i++) {
        if(place_free(x+hspeed, y-i)) {
            vspeed = -1*i;
            break;
        }
    }
} else if(!isFalling && hspeed > 0 && place_free(x+hspeed, y+vspeed) && !place_free(x+hspeed, y+PLAYER_SLOPE_HEIGHT*hspeed+1)) { //Down with pos hspeed
    for ( i = 0; i <= PLAYER_SLOPE_HEIGHT*hspeed+1; i++) {
        if(!place_free(x+hspeed, y+vspeed+i)) {
            vspeed = i-1;
            break;
        }
    }
} else if(!isFalling && hspeed < 0 && place_free(x+hspeed, y+vspeed) && !place_free(x+hspeed, y+PLAYER_SLOPE_HEIGHT*hspeed*-1+1)) { //Down with neg hspeed
    for ( i = 0; i <= PLAYER_SLOPE_HEIGHT*hspeed*-1+1; i++) {
        if(!place_free(x+hspeed, y+i)) {
            vspeed = i-1;
            break;
        }
    }
}*/

//Jumping
if (keyboard_check(global.settingsID.key_jump) && !isFalling && !isJumpHeld) {
    vspeed = -1*PLAYER_SPEED_JUMP;
    isFalling = true;
    isJumpHeld = true;
    audio_play_sound(player_jump_start, 1, false);
} else if (!keyboard_check(global.settingsID.key_jump) && isJumpHeld) {
    isJumpHeld = false; // allow buffered inputs but prevent simply holding jump
}

//Falling
if (place_free(x+hspeed, y+vspeed+1) && !isFalling)
    isFalling = true; //fall if not on ground
    
if (isFalling && vspeed + GRAVITY < GRAVITY_TERMINAL) { //gravity affects speed
    vspeed += GRAVITY;
} else if (isFalling && vspeed + GRAVITY >= GRAVITY_TERMINAL) {
    vspeed = GRAVITY_TERMINAL;
}

//Alt Collision
if(!place_free(x+hspeed, y+vspeed)) {
    if(collision_point(x+hspeed/abs(hspeed), y, tile_block, false, true) != noone && collision_point(x+hspeed/abs(hspeed), y, tile_block, false, true).isSlope) { //upward slope handling
        if(vspeed >= 0) {
            for(i = vspeed; i > -1*abs(hspeed)*PLAYER_SLOPE_HEIGHT; i--) {
                if(place_free(x+hspeed, y+i)){
                    vspeed = i;
                    if(isFalling) {
                        audio_play_sound(player_jump_end, 1, false);
                        isFalling = false;
                    }
                    break;
                }
            }
        } //insert head collision
    } else { //normal block collision
        if(vspeed > 0 ) { //falling/downslope collision
            if(hspeed != 0) {
                for (i = abs(hspeed); i >=0; i-- ) {
                    if(place_free(x+i*hspeed/abs(hspeed), y)) {
                        hspeed = i*hspeed/abs(hspeed);
                        for (j = vspeed-1; j >= 0; j--) {
                            if(place_free(x+hspeed, y+j)) {
                                vspeed = j;
                                if(isFalling && !place_free(x+hspeed, y+j+1)) {
                                    audio_play_sound(player_jump_end, 1, false);
                                    isFalling = false;
                                }
                                break;
                            }
                        }
                        break;
                    }
                }
            } else {
                for (j = vspeed-1; j >= -1 ; j--) {
                    if(place_free(x+hspeed, y+j)) {
                        vspeed = j;
                        if(isFalling && !place_free(x+hspeed, y+j+1)) {
                            audio_play_sound(player_jump_end, 1, false);
                            isFalling = false;
                        }
                        break;
                    }
                }
            }
        } else if(vspeed <= 0) { //horizontal collision
            for(i = abs(hspeed); i >= -1; i--) {
                if(place_free(x+hspeed/abs(hspeed)*i, y)) {
                    hspeed = hspeed/abs(hspeed)*i;
                    break;
                }
            }
        }
    }
} else if (collision_point(x+hspeed, y+vspeed+abs(hspeed)*PLAYER_SLOPE_HEIGHT, tile_block, false, true) != noone && 
           collision_point(x+hspeed, y+vspeed+abs(hspeed)*PLAYER_SLOPE_HEIGHT, tile_block, false, true).isSlope) { //downward slope handling
    
}

/*//Collision
if (!place_free(x+hspeed, y+vspeed)) {
    isFree = false;
    isMaxHspeed = false;
    if (isFalling) { //Falling X
        if ( hspeed >= 0 ){ //Check all possible points
            for (i = hspeed; i>= 0 && !isMaxHspeed; i--) { // Max possible hspeed
                if ( place_free(x+i, y) ) {
                    hspeed = i;
                    isMaxHspeed = true;
                }
            }
            for (i = hspeed; i >= 0 && !isFree; i--) {
                if (vspeed >= 0) {
                    for ( j = vspeed; j >= 0 && !isFree; j--) {
                        if( place_free(x+i, y+j) ) {
                            hspeed = i;
                            vspeed = j;
                            if( !place_free(x+i, y+j+1) )
                                isFalling = false;
                                audio_play_sound(player_jump_end, 1, false);
                            isFree = true;
                        }
                    }
                } else {
                    for ( j = vspeed; j <= 0 && !isFree; j++) {
                        if( place_free(x+i, y+j) ) {
                            hspeed = i;
                            vspeed = j;
                            isFree = true;
                        }
                    }
                }
            }
        } else {
            for (i = hspeed; i<= 0 && !isMaxHspeed; i++) { // Max possible hspeed
                if ( place_free(x+i, y) ) {
                    hspeed = i;
                    isMaxHspeed = true;
                }
            }
            for (i = hspeed; i <= 0 && !isFree; i++) {
                if (vspeed >= 0) {
                    for ( j = vspeed; j >= 0 && !isFree; j--) {
                        if( place_free(x+i, y+j) ) {
                            hspeed = i;
                            vspeed = j;
                            if( !place_free(x+i, y+j+1) )
                                isFalling = false;
                                audio_play_sound(player_jump_end, 1, false);
                            isFree = true;
                        }
                    }
                } else {
                    for ( j = vspeed; j <= 0 && !isFree; j++) {
                        if( place_free(x+i, y+j) ) {
                            hspeed = i;
                            vspeed = j;
                            isFree = true;
                        }
                    }
                }
            }
        }
    } else {
        if ( hspeed > 0 ) {
            for (i = hspeed; i >= 0; i--) {
                if ( place_free(x+i, y+vspeed) ) {
                    hspeed = i;
                    isFree = true;
                }
            }
        } else {
            for (i = hspeed; i <= 0; i++) {
                if ( place_free(x+i, y+vspeed) ) {
                    hspeed = i;
                    isFree = true;
                }
            }
        }
    }
}
if (!place_free(x+hspeed, y+vspeed)) { //Y Catch
    isFree = false;
    for ( j = -1; j < -1*PLAYER_SAFETY && !isFree; j-- ) {
        if (place_free(x+hspeed, y+vspeed+j)) {
            y += vspeed + j;
            vspeed = 0;
            isFalling = false;
            isFree = true;
        }
    }
}*/

//Sprint check and drain
if (isSprinting) {
    sprintMeter -= PLAYER_SPRINT_DRAIN;
    if(sprintMeter <= 0) {
        isSprinting = false;
        sprintMeter = 0;
    }
} else if (sprintMeter < PLAYER_SPRINT_MAX) { //Sprint recovery
    sprintMeter += getRecovery(self);
    if(sprintMeter > PLAYER_SPRINT_MAX)
        sprintMeter = PLAYER_SPRINT_MAX;
}

x+=hspeed;
y+=vspeed;
