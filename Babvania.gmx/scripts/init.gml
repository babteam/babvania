///Initialization Logic
//Handles necessary setup on game start

global.settingsID = settings.id; //Stores ID of settings object

instance_deactivate_object(global.settingsID);

global.settingsID.key_left = vk_left;
global.settingsID.key_right = vk_right;
global.settingsID.key_up = vk_up;
global.settingsID.key_down = vk_down;
global.settingsID.key_sprint = vk_shift;
global.settingsID.key_jump = ord('Z');
global.settingsID.key_shoot = ord('X');
global.settingsID.key_potty = ord('A');
