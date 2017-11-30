#!/usr/bin/env roseus

(load "package://turtleboteus/euslisp/turtlebot-interface.l")
(turtlebot-init)

(load "package://roseus/test/joy.l")
(init-ps3joy)

(ros::load-ros-manifest "roseus")
(ros::load-ros-manifest "kobuki_msgs")

(ros::roseus "joy-sound")
(ros::advertise "/mobile_base/commands/sound" kobuki_msgs::Sound 1)
(ros::advertise "/mobile_base/commands/led1" kobuki_msgs::Led 1)

(setq sound-msg (instance kobuki_msgs::Sound :init))
(send sound-msg :value 6)

(setq led-msg (instance kobuki_msgs::Led :init))
(send led-msg :value 1)

(progn
  (ros::rate 5)
  (warn "~%circle button : sound~%")
  (warn "triangle button : led on~%")
  (warn "cross button : led off~%")
  (warn "left button : move left~%")
  (warn "right button : move right~%")
  (do-until-key
    (ros::spin-once)
    (ros::sleep)
    (cond
      ((= (send *joy* :circle-button) 1)
       (ros::publish "/mobile_base/commands/sound" sound-msg))
      ((= (send *joy* :triangle-button) 1)
       (send led-msg :value 1)
       (ros::publish "/mobile_base/commands/led1" led-msg))
      ((= (send *joy* :cross-button) 1)
       (send led-msg :value 0)
       (ros::publish "/mobile_base/commands/led1" led-msg))
      ((= (send *joy* :left-button) 1)
       (send *ri* :go-velocity 0 0 30))
      ((= (send *joy* :right-button) 1)
       (send *ri* :go-velocity 0 0 -30))
      (t ))))
