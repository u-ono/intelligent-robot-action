#!/bin/bash
roslaunch roseus_tutorials checkerboard-detector.launch rect0_size_x:=0.025 rect0_size_y:=0.025 grid0_size_x:=5 grid0_size_y:=4 transition0:="0 0 0" image:=image_rect_mono group:=/camera/rgb frame_id:=camera_rgb_frame
