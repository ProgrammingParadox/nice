class_name PlayerContext
extends Resource

var time_since_on_ground = INF
var time_since_left_wall_touch = INF
var time_since_right_wall_touch = INF
var time_since_last_wall_jump = INF

var time_since_jump_pressed = INF
var time_since_last_jump_pressed = INF

var time_since_left_pressed = INF
var time_since_right_pressed = INF

var jumps = 0

var gravity_mod := 1.0
